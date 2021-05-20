#!/usr/bin/python3

import sys
import json
import signal
import urllib.request as urllib
import threading
import pyperclip
import time

class Dict:
    key = '716426270'
    keyFrom = 'wufeifei'
    api = 'http://fanyi.youdao.com/openapi.do?keyfrom=wufeifei&key=716426270&type=data&doctype=json&version=1.1&q='
    content = None

    def __init__(self, argv):
        try:
            self.api = self.api + urllib.quote(argv)
            self.translate()
        except:
            print("Input invalid！！")

    def translate(self):
        content = urllib.urlopen(self.api).read()
        self.content = json.loads(content)
        self.parse()

    def parse(self):
        code = self.content['errorCode']
        if code == 0:  # Success
            try:
                u = self.content['basic']['us-phonetic'] # English
                e = self.content['basic']['uk-phonetic']
            except KeyError:
                try:
                    c = self.content['basic']['phonetic'] # Chinese
                except KeyError:
                    c = 'None'
                u = 'None'
                e = 'None'

            try:
                explains = self.content['basic']['explains']
            except KeyError:
                explains = 'None'

            print('\033[1;31m################################### \033[0m')
            # flag
            #print('\033[1;31m# \033[0m', self.content['query'], self.content['translation'][0], end="")
            print('\033[1;31m# \033[0m', self.content['query'], self.content['translation'][0])
            if u != 'None':
                print('(U:', u, 'E:', e, ')')
            elif c != 'None':
                print('(Pinyin:', c, ')')
            else:
                print()

            if explains != 'None':
                for i in range(0, len(explains)):
                    print('\033[1;31m# \033[0m', explains[i])
            else:
                print('\033[1;31m# \033[0m Explains None')
            print('\033[1;31m################################### \033[0m')
            # Phrase
            # for i in range(0, len(self.content['web'])):
            #     print self.content['web'][i]['key'], ':'
            #     for j in range(0, len(self.content['web'][i]['value'])):
            #         print self.content['web'][i]['value'][j]
        elif code == 20:  # Text to long
            print('WORD TO LONG')
        elif code == 30:  # Trans error
            print('TRANSLATE ERROR')
        elif code == 40:  # Don't support this language
            print('CAN\'T SUPPORT THIS LANGUAGE')
        elif code == 50:  # Key failed
            print('KEY FAILED')
        elif code == 60:  # Don't have this word
            print('DO\'T HAVE THIS WORD')


class Clipboard (threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.raw = "Welcome!!"

    def run(self):
        global exitflag
        while not exitflag:
            time.sleep(0.5)
            new_raw = pyperclip.paste()
            if new_raw != self.raw:
                self.raw = new_raw
                words = self.raw.split(",")
                print()
                for word in words:
                    Dict(word)
                # 这里为什么不显示诶????
                print(">>>", end="", flush=True)


class Outinput (threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)

    def run(self):
        global exitflag
        while not exitflag:
            raw = input(">>>")
            words = raw.split(",")
            if words == ['exit']:
                exitflag = True
            else:
                for word in words:
                    Dict(word)


def quit():
    print("bye!!")
    sys.exit()

if __name__ == '__main__':
    exitflag = False

    try:
        signal.signal(signal.SIGINT, quit)
        signal.signal(signal.SIGTERM, quit)
        
        thread1 = Clipboard()
        thread2 = Outinput()

        thread1.setDaemon(True)
        thread1.start()

        thread2.setDaemon(True)     
        thread2.start()
        
        thread1.join()
        thread2.join()
        print("bye!!")
    except:
        print()

