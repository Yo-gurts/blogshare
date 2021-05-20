---
author: yogurt
date: 2020-01-31 10:03:49
---


# Chapter3 New Features

* 空指针 `nullptr`
* 自动处理变量类型 `auto`
```cpp
    auto p = 1.2;

    vector<string> v;
    auto pos = v.begin();

    // l has the type of a lambda
    // taking an int and returning a bool
    auto l = [] (int x) -> bool {
        ...,
    };
```
* 统一的初始化语法 `{}`
```cpp
    int values[] { 1, 2, 3 };
    std::vector<int> v { 2, 3, 5, 7, 11, 13, 17 };
    std::vector<std::string> cities {
        "Berlin", "New York", "London", "Braunschweig", "Cairo", "Cologne"
    };

    int i;      // i has undefined value
    int j{};    // j is initialized by 0
    int* p;     // p has undefined value
    int* q{};   // q is initialized by nullptr
```
* for循环 `for ( decl : coll )`
```cpp
    for ( int i : { 2, 3, 5, 7, 9, 13, 17, 19 } ) {
        std::cout << i << std::endl;
    }
    std::vector<double> vec;
    ...
    for ( auto& elem : vec ) {
        elem *= 3;
    }
```
* 原格式字符串 `string str = R"xx(anythinghere)xx";` `<string>`
```cpp
string str = R"xx(123
    456             // 想换行也只能这样换行，输入\n会原样输出
        789)xx"; 
    cout<<str<<endl;
```
* 支持用变量来定义数组长度 `constexpr` 好像不用也行
```cpp
    int number;
    cin>>number;
    int a[number] = {1,2,3,4,5};
```

* `lambda`
```cpp
    auto fun2=[](int n) -> double { // 输入参数n, 返回类型 double
        cout<<n<<"hello lambda!"<<endl;
        return n*2;
    };

    auto fun4=[=, &m] { // = 全部变量只读, & 引用m
        n*=3;   // Error, 只读变量
        m*=4;
    };

    // mutable
```
* 自定义变量位数 `bitset<32> var32;`
* 模板默认参数 `template <typename T, typename container = vector<T>>`

# Chapter5 Utilities

* 数值对 `pair` `<utility>`
```cpp
    typedef std::pair<int, double> intdoublepair;
    using mypair = std::pair<int, double>;

    pair<int, double> p1(12, 13.3); // 元素类型也可以是引用
    pair<int, double> p2(10, 15.3);
    cout<<p1.first<<", "<<p1.second<<endl;
    p1.swap(p2);
    swap(p1, p2);

    intdoublepair p3 = p1;
    mypair p4 = p2;
    cout<<p3.first<<", "<<p3.second<<endl;
    cout<<get<0>(p3)<<", "<<get<1>(p4)<<endl;  

    auto p5 = make_pair(3,4);
    cout<<p5.first<<", "<<p5.second<<endl;
```
* 数值组 `tuple`， 类似`pair`但元素可多个   `<tuple>`
```cpp
    tuple<int, float, double, string> p1{2, 3.3, 4.44, "hello"};
    tuple<int, float, double, string> p2(2, 3.3, 4.44, "hello");
    auto p3 = make_tuple(2, 3.3, 4.44, "hello");
    string str = "hi";
    tuple<int, float, double, string&> p4(2, 3.3, 4.44, str);
    cout<<get<0>(p1)<<", "<<get<3>(p1)<<endl;
    cout<<get<0>(p2)<<", "<<get<3>(p2)<<endl;
    cout<<get<0>(p3)<<", "<<get<3>(p3)<<endl;
    cout<<get<0>(p4)<<", "<<get<3>(p4)<<endl;
    str = "hello";
    cout<<get<0>(p4)<<", "<<get<3>(p4)<<endl;
    p1.swap(p2)
    swap(p1,p2)
```
* 智能指针－－共享指针 `shared_ptr` `<memory>`


# Chapter7 Containers
* 容器通用初始化方法
``` cpp
    // 以下方法各容器普遍适用, 这里以vector为例
    vector<int> c1{};
    vector<int> c2{1,2,3,4};
    vector<int> c3(c2);
    vector<int> c4 = c3;
    vector<int> c5(c2.begin(), c2.begin()+2);
    vector<int> c6(20);     // (n)  分配空间
    vector<int> c7(3, 100); // (n, elements)

    c1.swap(c2);    // exchange elements of c1, c2;
    swap(c1, c2);   // same with up

    c.size();       // return the current size
    c.empty();      // check if c is empty, 
    c.begin();      // return a iterator
    c.end();        
    c.clear();      // clear all elements
```
* vecotr `<vector>` [cpluscplus.com/vector](http://www.cplusplus.com/reference/vector/vector/assign/)
``` cpp
    vector::assign          // v.assign (7,100);  
                            // v.assign (c.first(), c.end());
                            // v.assign ({1,2,3,4,6});
    vector::at
    vector::back            // return the last value;
    vector::begin           
    vector::capacity        
    vector::cbegin          // const _ begin()
    vector::cend
    vector::clear           // size = 0, but capacity will not change
    vector::crbegin         // const reverse begin()
    vector::crend   
    vector::data            // returns a direct pointer to the memory array
    vector::emplace         // insert value, likely
    vector::emplace_back    // push_back, likely
    vector::empty   
    vector::end
    vector::erase           // (begin()+3); (begin(), end());
                            // size changed, capacity remains the same
    vector::front           // return the first value;
    vector::get_allocator   // p = myvector.get_allocator().allocate(5);
                            // myvector.get_allocator().construct(&p[i],i);
                            // myvector.get_allocator().destroy(&p[i]);
                            // myvector.get_allocator().deallocate(p,5);                    
    vector::insert          // myvector.insert ( begin() , 200 );
                            // myvector.insert ( begin() , 3, 300 );
                            // myvector.insert (begin()+2, anothervector.begin(), anothervector.end());
                            // myvector.insert (myvector.begin(), myarray, myarray+3);
    vector::max_size
    vector::operator=
    vector::operator[]
    vector::pop_back        // clear last value, size - 1
    vector::push_back
    vector::rbegin          // reverse begin
    vector::rend
    vector::reserve
    vector::resize          // resize(n);
                            // resize(n, 100); set default value 100
    vector::shrink_to_fit   // reduce capacity to fit size.
    vector::size
    vector::swap
```

* list `<list>` [cplusplus.com/list](http://www.cplusplus.com/reference/list/list/)
``` cpp
    list::assign        // l.assign(n, elements);
                        // l.assign(l2.begin(), l2.end());
                        // l.assign(array, array+3);
    list::back          // return the last value
    list::begin         
    list::cbegin        // const begin
    list::cend
    list::clear         
    list::crbegin
    list::crend
    list::emplace
    list::emplace_back  
    list::emplace_front 
    list::empty
    list::end
    list::erase         
    list::front
    list::get_allocator
    list::insert
    list::max_size
    list::merge
    list::operator=
    list::pop_back
    list::pop_front
    list::push_back
    list::push_front
    list::rbegin
    list::remove        // remove(n); remove all values equals n
    list::remove_if     
    // mylist.remove_if ([](const int &value) -> bool{ return (value<10);});
    list::rend
    list::resize
    list::reverse
    list::size
    list::sort
    list::splice
    list::swap
    list::unique        // remove repeated or satisfied some conditions
```
