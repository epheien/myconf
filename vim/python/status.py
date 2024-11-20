#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import json
import texttable
import time
import argparse

g_optarg = None

def make_tsdt(ts):
    '''
    ts 为 '2020-01-01 00:00:00' 或 1577808000 的形式
    return (1577808000, '2020-01-01 00:00:00') # 固定为 GMT+8 时区
    '''
    timefmt = '%Y-%m-%d %H:%M:%S'
    if isinstance(ts, str):
        dt = ts
        if ' ' not in dt:
            # '2020-01-01' => '2020-01-01 00:00:00'
            dt += ' 00:00:00'
        # 支持 2020/01/01
        dt = dt.replace('/', '-')
        ts = time.mktime(time.strptime(dt, '%Y-%m-%d %H:%M:%S'))
    else:
        # 我们用秒数偏移来处理时区即可 28800 (GMT+8)
        dt = time.strftime(timefmt, time.gmtime(ts + 28800))
    return ts, dt

def render_table(*tables):
    if not tables:
        return

    ts = []
    for table in tables:
        if isinstance(table, (list, tuple)):
            for t in table:
                ts.append(t)
        else:
            ts.append(table)

    lines = []
    prec = 8
    for table in ts:
        tab = texttable.Texttable(0)
        tab.set_precision(prec)
        tab.set_deco(texttable.Texttable.HEADER |
                     texttable.Texttable.VLINES |
                     texttable.Texttable.BORDER)

        header = []
        for i in table['cols']:
            header.append(i)

        tab.header(header)
        align = ['c'] * len(table['cols'])
        tab.set_cols_align(align)
        tab.set_cols_dtype(['t'] * len(table['cols']))
        tab.add_rows(table['rows'], header=False)
        text = ('===== %s =====\n' % table.get('title', '')) + tab.draw()
        lines.append(text)
    return '\n'.join(lines)

def get_arg_parser():
    example_text = '''examples:
    {cmd} --help
    {cmd} {{config.json|default.status}}
    '''.format(cmd=sys.argv[0])

    parser = argparse.ArgumentParser(add_help=False,
                                     epilog=example_text,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-h', '--help', action='help',
                        help='show this help message and exit')
    parser.add_argument('--version', action='version', version='%(prog)s 1.0')
    parser.add_argument('-v', '--verbose',
                        dest='verbose',
                        action='store_true',
                        default=False,
                        help='verbose information')

    parser.add_argument('-f', '--filter',
                        dest='filters',
                        action='append',
                        default=[],
                        help='title for filter, can be specify multiple')

    # 最后的参数列表
    parser.add_argument('args', action='store', nargs='+', help='args')

    return parser

def render_status(fname, filters=[]):
    lines = ''
    lines += '当前时间: ' + str(make_tsdt(time.time())[1]) + '\n'
    with open(fname) as f:
        for line in f:
            if line.startswith('{'):
                table = json.loads(line)
                if table.get('title') in filters:
                    continue
                lines += render_table(table) + '\n'
            else:
                lines += line
    return lines.strip().split('\n')
