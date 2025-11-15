#!/usr/bin/env python3
"""
CGWindow HTTP 服务器
监听端口: 7749
"""

import Quartz
import json
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
import sys


class WindowInfo:
    @staticmethod
    def is_valid_window(window):
        """判断窗口是否是有效的应用窗口"""
        layer = window.get("kCGWindowLayer", 0)
        owner_name = window.get("kCGWindowOwnerName", "")
        bounds = window.get("kCGWindowBounds", {})
        alpha = window.get("kCGWindowAlpha", 1.0)

        # 无效的窗口拥有者
        invalid_owners = ["Window Server", "程序坞", "Dock", "通知中心"]

        # 层级范围
        valid_layer = -10 < layer < 1000

        # 有效的拥有者
        valid_owner = owner_name not in invalid_owners

        # 有效的尺寸
        width = bounds.get("Width", 0)
        height = bounds.get("Height", 0)
        valid_size = width > 50 and height > 50

        # 足够的透明度
        valid_alpha = alpha > 0.5

        # Finder 特殊处理
        if owner_name in ["访达", "Finder"]:
            return layer >= 0

        return valid_layer and valid_owner and valid_size and valid_alpha

    @staticmethod
    def get_all_windows(check_valid=True):
        """获取所有有效窗口(包括所有层级)"""
        window_list = Quartz.CGWindowListCopyWindowInfo(
            Quartz.kCGWindowListOptionOnScreenOnly, Quartz.kCGNullWindowID
        )

        result = []
        for window in window_list:
            if not check_valid or WindowInfo.is_valid_window(window):
                bounds = window.get("kCGWindowBounds", {})

                result.append(
                    {
                        "index": len(result),
                        "windowNumber": window.get("kCGWindowNumber"),
                        "ownerName": window.get("kCGWindowOwnerName", ""),
                        "windowName": window.get("kCGWindowName", ""),
                        "ownerPID": window.get("kCGWindowOwnerPID"),
                        "layer": window.get("kCGWindowLayer", 0),
                        "x": int(bounds.get("X", 0)),
                        "y": int(bounds.get("Y", 0)),
                        "width": int(bounds.get("Width", 0)),
                        "height": int(bounds.get("Height", 0)),
                        "alpha": window.get("kCGWindowAlpha", 1.0),
                    }
                )

        return result


class WindowServerHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        """禁用默认的日志输出"""
        pass

    def do_GET(self):
        """处理GET请求"""
        if self.path == "/orderedWindows":
            try:
                windows = WindowInfo.get_all_windows()

                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.end_headers()

                response = json.dumps(windows, ensure_ascii=False)
                self.wfile.write(response.encode("utf-8"))

            except Exception as e:
                self.send_response(500)
                self.send_header("Content-Type", "application/json")
                self.end_headers()

                error = {"error": str(e)}
                self.wfile.write(json.dumps(error).encode("utf-8"))

        elif self.path == "/allWindows":
            try:
                windows = WindowInfo.get_all_windows(check_valid=False)

                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.end_headers()

                response = json.dumps(windows, ensure_ascii=False)
                self.wfile.write(response.encode("utf-8"))

            except Exception as e:
                self.send_response(500)
                self.send_header("Content-Type", "application/json")
                self.end_headers()

                error = {"error": str(e)}
                self.wfile.write(json.dumps(error).encode("utf-8"))

        elif self.path == "/ping":
            # 健康检查
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok"}).encode("utf-8"))

        elif self.path == "/shutdown":
            # 关闭服务器
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "shutting down"}).encode("utf-8"))

            # 在新线程中关闭服务器
            threading.Thread(target=self.server.shutdown).start()

        else:
            self.send_response(404)
            self.send_header("Content-Type", "application/json")
            self.end_headers()

            error = {
                "error": "Not Found",
                "available_endpoints": ["/orderedWindows", "/ping", "/shutdown"],
            }
            self.wfile.write(json.dumps(error).encode("utf-8"))


def run_server(port=7749):
    """启动HTTP服务器"""
    server = HTTPServer(("127.0.0.1", port), WindowServerHandler)

    print(f"CGWindow HTTP Server started on http://127.0.0.1:{port}")
    print(f"Available endpoints:")
    print(f"  - http://127.0.0.1:{port}/orderedWindows")
    print(f"  - http://127.0.0.1:{port}/allWindows")
    print(f"  - http://127.0.0.1:{port}/ping")
    print(f"  - http://127.0.0.1:{port}/shutdown")
    print(f"\nPress Ctrl+C to stop")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
        print("Server stopped")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="CGWindow HTTP Server")
    parser.add_argument(
        "--port", type=int, default=7749, help="Port to listen on (default: 7749)"
    )

    args = parser.parse_args()
    run_server(args.port)
