# 基于 WSGI 标准创建一个简单的 REST 接口

> 参考 PythonCookbook  11.5 [创建一个简单的 REST 接口](https://python3-cookbook.readthedocs.io/zh_CN/latest/c11/p05_creating_simple_rest_based_interface.html)

1. `resty.py`, `server1.py`是 书上面的代码
   * 浏览器访问是，`http://localhost:8080/hello?name=joke` 指定name
   * [what-does-the-yield-keyword-do](https://stackoverflow.com/questions/231767/what-does-the-yield-keyword-do)

2. 测试是否可用类的函数作为server的处理函数！`serverByClass.py`， 结论：
   * 函数声明时加上`self`即可，`def localtime(self, environ, start_response):`
   * 函数内仍然可正常访问类的成员变量， line 37 `resp = _hello_resp.format(name=self.name)`
