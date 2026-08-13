// Kitty-style cursor trail for Ghostty.
//
// This recreates kitty's native cursor trail model: the four corners of the
// previous cursor rectangle chase the matching corners of the current cursor
// at direction-dependent exponential decay rates. The leading corners use the
// fast decay and the trailing corners use the slow decay, stretching the old
// rectangle into a comet-like quadrilateral.
//
// Ghostty custom shaders do not have writable state between frames, so every
// movement starts from iPreviousCursor. This matches a settled kitty trail for
// each individual move, but rapid changes of direction cannot carry the exact
// corner positions from the preceding animation.
//
// Add to the Ghostty configuration:
//   custom-shader = /absolute/path/to/kitty_cursor_trail.glsl

// Equivalents of these kitty settings:
//   cursor_trail 25
//   cursor_trail_decay 0.1 0.5
//   cursor_trail_start_threshold 2
//
// cursor_trail is milliseconds to wait before accepting a new cursor target.
const float CURSOR_TRAIL_DELAY_MS = 25.0;

// Each decay value is the time in seconds for a corner to reduce its remaining
// distance to 1/1024 of the original distance.
const vec2 CURSOR_TRAIL_DECAY = vec2(0.10, 0.50); // fast, slow

// Ghostty does not expose the cell size to custom shaders, so block cursors
// use their rectangle as the cell and bar/underline cursors use the
// aspect-ratio estimate below. Set this to vec2(0.0) to animate every move.
const vec2 CURSOR_TRAIL_START_THRESHOLD = vec2(2.0);
const float CELL_WIDTH_TO_HEIGHT = 0.5;

const float TRAIL_OPACITY = 1.0;
const float ANTIALIAS_PIXELS = 0.75;

float cross2d(vec2 a, vec2 b) {
    return a.x * b.y - a.y * b.x;
}

float distanceToSegment(vec2 point, vec2 start, vec2 end) {
    vec2 segment = end - start;
    float t = clamp(
        dot(point - start, segment) / max(dot(segment, segment), 1e-6),
        0.0,
        1.0
    );
    return length(point - (start + segment * t));
}

// Signed distance to a convex quadrilateral. The sign test accepts either
// winding direction so this works with both OpenGL and Metal coordinates.
float sdQuad(vec2 point, vec2 c0, vec2 c1, vec2 c2, vec2 c3) {
    float w0 = cross2d(c1 - c0, point - c0);
    float w1 = cross2d(c2 - c1, point - c1);
    float w2 = cross2d(c3 - c2, point - c2);
    float w3 = cross2d(c0 - c3, point - c3);

    float minWinding = min(min(w0, w1), min(w2, w3));
    float maxWinding = max(max(w0, w1), max(w2, w3));
    bool inside = minWinding >= 0.0 || maxWinding <= 0.0;

    float distance = min(
        min(distanceToSegment(point, c0, c1), distanceToSegment(point, c1, c2)),
        min(distanceToSegment(point, c2, c3), distanceToSegment(point, c3, c0))
    );
    return inside ? -distance : distance;
}

float sdBox(vec2 point, vec2 center, vec2 halfSize) {
    vec2 delta = abs(point - center) - halfSize;
    return length(max(delta, vec2(0.0))) + min(max(delta.x, delta.y), 0.0);
}

vec2 cursorCenter(vec4 cursor) {
    // iCurrentCursor.xy is the left/+Y corner. Subtracting half the height
    // therefore works for the API-specific coordinate convention Ghostty uses.
    return cursor.xy + vec2(cursor.z * 0.5, -cursor.w * 0.5);
}

void cursorCorners(
    vec4 cursor,
    out vec2 c0,
    out vec2 c1,
    out vec2 c2,
    out vec2 c3
) {
    float left = cursor.x;
    float right = cursor.x + cursor.z;
    float top = cursor.y;
    float bottom = cursor.y - cursor.w;

    // Same logical order as kitty: top-right, bottom-right, bottom-left,
    // top-left. The actual screen-space winding may differ between APIs.
    c0 = vec2(right, top);
    c1 = vec2(right, bottom);
    c2 = vec2(left, bottom);
    c3 = vec2(left, top);
}

vec2 estimatedCellSize(vec4 currentCursor, vec4 previousCursor) {
    vec2 size = max(currentCursor.zw, previousCursor.zw);

    if (iCurrentCursorStyle == CURSORSTYLE_BAR) {
        size.x = max(size.x, size.y * CELL_WIDTH_TO_HEIGHT);
    } else if (iCurrentCursorStyle == CURSORSTYLE_UNDERLINE) {
        size.y = max(size.y, size.x / CELL_WIDTH_TO_HEIGHT);
    }

    return max(size, vec2(1.0));
}

// This is the dot-product ranking used by kitty to decide which corners lead
// and which trail. A corner pointing in the direction of travel gets a larger
// value and therefore the faster decay.
float cornerDirection(
    vec2 previousCorner,
    vec2 currentCorner,
    vec2 currentCenter,
    float cursorHalfDiagonal
) {
    vec2 remaining = currentCorner - previousCorner;
    float remainingLength = length(remaining);
    if (remainingLength < 1e-5) {
        return 0.0;
    }

    return dot(remaining, currentCorner - currentCenter) /
        max(cursorHalfDiagonal * remainingLength, 1e-5);
}

vec2 animateCorner(
    vec2 previousCorner,
    vec2 currentCorner,
    float direction,
    float minDirection,
    float maxDirection,
    float elapsed
) {
    float rank = maxDirection - minDirection < 1e-5
        ? 0.0
        : (direction - minDirection) / (maxDirection - minDirection);
    float decay = mix(
        CURSOR_TRAIL_DECAY.y,
        CURSOR_TRAIL_DECAY.x,
        clamp(rank, 0.0, 1.0)
    );

    // kitty updates by: step = 1 - exp2(-10 * dt / decay). Because this is an
    // exponential process, its closed form from the previous cursor is exact
    // for a corner whose decay rank remains constant.
    float progress = 1.0 - exp2(-10.0 * elapsed / max(decay, 1e-5));
    return mix(previousCorner, currentCorner, progress);
}

vec4 trailColor() {
    // Ghostty supplies cursor colors in the alpha-blending color space selected
    // by the user, so no additional sRGB/linear conversion should be applied.
    // Replace this return value with a constant vec4 to set a custom color.
    return iCurrentCursorColor;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 source = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = source;

    if (iCursorVisible == 0 || iFocus == 0) {
        return;
    }
    if (iCurrentCursor.z <= 0.0 || iCurrentCursor.w <= 0.0 ||
        iPreviousCursor.z <= 0.0 || iPreviousCursor.w <= 0.0) {
        return;
    }

    // A cursor shape change is not movement and otherwise looks like a short
    // diagonal jump because differently sized rectangles have different centers.
    if (iCurrentCursorStyle != iPreviousCursorStyle) {
        return;
    }

    vec2 currentCenter = cursorCenter(iCurrentCursor);
    vec2 previousCenter = cursorCenter(iPreviousCursor);
    vec2 movement = currentCenter - previousCenter;

    vec2 movementInCells = floor(
        abs(movement) / estimatedCellSize(iCurrentCursor, iPreviousCursor) + 0.5
    );
    if (movementInCells.x <= CURSOR_TRAIL_START_THRESHOLD.x &&
        movementInCells.y <= CURSOR_TRAIL_START_THRESHOLD.y) {
        return;
    }

    float elapsedSinceChange = max(iTime - iTimeCursorChange, 0.0);
    float delay = CURSOR_TRAIL_DELAY_MS / 1000.0;
    if (elapsedSinceChange < delay) {
        return;
    }
    float elapsed = elapsedSinceChange - delay;

    vec2 previous0;
    vec2 previous1;
    vec2 previous2;
    vec2 previous3;
    vec2 current0;
    vec2 current1;
    vec2 current2;
    vec2 current3;
    cursorCorners(iPreviousCursor, previous0, previous1, previous2, previous3);
    cursorCorners(iCurrentCursor, current0, current1, current2, current3);

    // kitty stops rendering once every corner is within half a pixel of its
    // target. The slow decay is an upper bound on any corner's remaining
    // distance.
    float maximumDistance = max(
        max(max(abs(current0.x - previous0.x), abs(current0.y - previous0.y)),
            max(abs(current1.x - previous1.x), abs(current1.y - previous1.y))),
        max(max(abs(current2.x - previous2.x), abs(current2.y - previous2.y)),
            max(abs(current3.x - previous3.x), abs(current3.y - previous3.y)))
    );
    float maximumRemaining = maximumDistance *
        exp2(-10.0 * elapsed / max(CURSOR_TRAIL_DECAY.y, 1e-5));
    if (maximumRemaining < 0.5) {
        return;
    }

    float halfDiagonal = length(iCurrentCursor.zw) * 0.5;
    float direction0 = cornerDirection(previous0, current0, currentCenter, halfDiagonal);
    float direction1 = cornerDirection(previous1, current1, currentCenter, halfDiagonal);
    float direction2 = cornerDirection(previous2, current2, currentCenter, halfDiagonal);
    float direction3 = cornerDirection(previous3, current3, currentCenter, halfDiagonal);
    float minDirection = min(min(direction0, direction1), min(direction2, direction3));
    float maxDirection = max(max(direction0, direction1), max(direction2, direction3));

    vec2 animated0 = animateCorner(
        previous0, current0, direction0, minDirection, maxDirection, elapsed
    );
    vec2 animated1 = animateCorner(
        previous1, current1, direction1, minDirection, maxDirection, elapsed
    );
    vec2 animated2 = animateCorner(
        previous2, current2, direction2, minDirection, maxDirection, elapsed
    );
    vec2 animated3 = animateCorner(
        previous3, current3, direction3, minDirection, maxDirection, elapsed
    );

    float trailDistance = sdQuad(
        fragCoord, animated0, animated1, animated2, animated3
    );
    float antialias = max(fwidth(trailDistance), ANTIALIAS_PIXELS);
    float coverage = 1.0 - smoothstep(-antialias, antialias, trailDistance);

    // Kitty punches the current cursor rectangle out of the trail so the real
    // cursor and its text stay crisp above the effect.
    float cursorDistance = sdBox(
        fragCoord,
        currentCenter,
        iCurrentCursor.zw * 0.5
    );
    coverage *= step(0.0, cursorDistance);

    vec4 color = trailColor();
    float opacity = clamp(coverage * TRAIL_OPACITY * color.a, 0.0, 1.0);
    fragColor = vec4(mix(source.rgb, color.rgb, opacity), source.a);
}
