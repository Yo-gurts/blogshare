import time
from resty import PathDispatcher
from wsgiref.simple_server import make_server

_hello_resp = '''\
<html>
    <head>
        <title>Hello {name}</title>
    </head>
    <body>
        <h1>Hello {name}!</h1>
    </body>
</html>'''


_localtime_resp = '''\
<?xml version="1.0"?>
<time>
    <year>{t.tm_year}</year>
    <month>{t.tm_mon}</month>
    <day>{t.tm_mday}</day>
    <hour>{t.tm_hour}</hour>
    <minute>{t.tm_min}</minute>
    <second>{t.tm_sec}</second>
</time>'''


class MyFunc:
    def __init__(self):
        self.name = "world!!"
        pass

    def hello_world(self, environ, start_response):
        start_response('200 OK', [ ('Content-type','text/html')])
        params = environ['params']
        # resp = _hello_resp.format(name=params.get('name'))
        resp = _hello_resp.format(name=self.name)
        yield resp.encode('utf-8')

    def localtime(self, environ, start_response):
        start_response('200 OK', [ ('Content-type', 'application/xml') ])
        resp = _localtime_resp.format(t=time.localtime())
        yield resp.encode('utf-8')


if __name__ == '__main__':

    # Create the dispatcher and register functions
    myfunc = MyFunc()
    dispatcher = PathDispatcher()
    dispatcher.register('GET', '/hello', myfunc.hello_world)
    dispatcher.register('GET', '/localtime', myfunc.localtime)

    # Launch a basic server
    httpd = make_server('', 8080, dispatcher)
    print('Serving on port 8080...')
    httpd.serve_forever()