---
title: 理解JavaScript原型/原型链
date: 2019-04-10 19:15:25
categories:
    - 大前端
    - javascript
tags:
    - 原型
    - 原型链
    - prototype
---

对于搞前端的小伙伴来说，不管是新手还是老鸟，我想对于原型应该都被折腾过，总是云里雾里的感觉，而且线上的文章教程一大堆，良莠不齐，因此我不自量力的想死扣一下原型这个东东，尽量能把这个问题讲清楚讲明白。



# 关于对象



当一说到面向对象(Object-Oriented OO)时，你第一反应肯定想到类、对象、接口实现等概念，那我们这里为啥已上来就说对象呢？因为ECMAScript里没有类，***另外因为ECMAScript中的函数没有签名，所以也没有接口***。



ECMAScript-262中对象定义为：“***无序属性的集合，其属性可以是基本值、对象或者函数***”。因此从数据结构的角度，可以把对象看成散列表(Hash Table)。



### 对象分类

从对象的创建方式上可以把对象分成：内置对象、宿主对象、自定义对象三大类。关于对象分类详细[点这里](https://zhimap.com/m/VpUWPHzp)。

特别需要强调的是，除了number、string、boolean、null、undefined这5中基本类型外，其它统统都是对象(引用类型)，包括函数，***所有的函数都是对象，反之则不成立***。



### 对象和函数的关系



### 对象的创建



前面说过，ECMAScript中没有类，那怎么创建对象呢？



##### 对象字面量

```javascript
// 方式一： 对象字面量
var zhangsan = {
    type: "人类",
    name: "张三",
    age: 18,
    greeting: function() {
        console.log(`hello I'am ${this.name}`);
    }
};
zhangsan.greeting(); // "hello I'am 张三"
```

该方式主要有一下几个问题：

- 当要创建多个变量的时候，不得不写大量重复代码；

- 每个实例都会持有一个greeting函数，但实际上功能都一样，没有复用，浪费资源；

- 创建所有“人类"(type="人类")的实例，type的值都是一样的，但是每个实例还是持有一个独立的副本；

- 创建实例无法识别类型(也就是说创建的实例具体是啥类型不知道，只知道它是Object的实例)。

  

##### 工厂模式

```javascript
// 方式二： 工厂模式
function createPerson (name, age) {
    var p = new Object();
    p.type = "人类";
    p.name = name;
    p.age = age;
    p.greeting = greeting;
    return p;
}
var lisi = createPerson ("李四", 20);
lisi.greeting(); // "hello I'am 李四"
function greeting () {
    console.log(`hello I'am ${this.name}`);
}
```

方式二虽然进行了封装，避免了创建时大量重复的代码，也通过把greeting抽离到全局作用域而解决了多个实例持有多个greeting副本的问题，但同时也给全局空间引入了一个只有该类型实例才会引用的函数，污染了全局空间；最后它也米有解决对象识别问题。



```javascript
// 方式三： 构造函数
function Person (name, age) {
    this.type = "人类";
    this.name = name;
    this.age = age;
    this.greeting = greeting;
}
var wangwu = new Person("王五", 24); // wangwu instanceof Person === true
wangwu.greeting(); // "hello I'am 王五"
function greeting () {
    console.log(`hello I'am ${this.name}`);
}
```

这个方式近乎完美了，解决了对象识别问题，但是任然没有解决共享函数污染全局空间的问题；为了解决这个问题，下面请出我们的主角prototype(原型)。



# 原型&原型链

终于切入正题了，要解决上面方式三面临的问题，就要有一个属于构造函数专有(不用定义到全局污染全局空间)，能够为构造函数创建的所有对象实例所共享的对象。这个对象就是原型(或称为原型对象)。

### 什么是原型(prototype)

默认情况下，任何函数都有一个属性`prototype`，它是一个指针，指向一个对象(原型对象)，原型对象的用途是包含特定类型实例所共享的属性和方法，默认原型对象只有一个`constructor`属性，我们可以给它定义更多属性和方法。

```javascript
// 方式四： 原型法
function Person (name, age) {
    this.name = name;
    this.age = age;
}
Person.prototype.type = "人类";
Person.prototype.greeting = function () {
    console.log(`hello I'am ${this.name}`);
};
var wangwu = new Person("王五", 24); // wangwu instanceof Person === true
wangwu.greeting(); // "hello I'am 王五"

```

那上面的实例wangwu是怎么找到原型对象里定义的greeting的呢？原因是所有的对象都有一个内部指针，指向实例构造函数的原型对象，ECMAScript-262第5版中称为`[[Prototype]]`，虽然标准并没有定义怎么访问这个内部指针，但是Firefox、Safari、Chrome在每个对象上都支持一个指向相同、名为`__proto__`指针属性。

在chrome console里查看wangwu的属性如下图：

![image-20190412003032272](/Users/david/Library/Application Support/typora-user-images/image-20190412003032272.png)



### 原型链查找

当对象实例访问某个属性或调用某个方法时，首先在自有属性里找，找到则返回值或发起调用，没有则沿着`__proto__`的指向往上找，直到最后查到Object.prototype,任然没有查到，即终止并报错。

对象实例、构造函数、构造函数的原型对象这三者的关系如下图：

![](http://xuh.cn-etc.com/2019/04/12/1554998544275.png)

上图中红色的路径及为查找方向，这条有`__proto__`指针串起来的链即为`原型链(prototype chain)`。***原型链的本质是一串顺序指向原型对象的指针列表***。



##### 原型的动态性

因为对象实例的`__proto__`仅仅是一个指向原型对象的指针，因此对原型对象的修改立即可以在实例上体现出来，哪怕这个实例在修改原型之前创建的：

```javascript
Person.prototype.work = function () {
    console.log('work function');
}
// 这里的wangwu是上面创建的实例,给原型增加work方法后，可以立即调用
wangwu.work(); // "work function"
```

但是如果重写整个原型对象后，相当于为构造函数指定了新的原型对象，而已创建的实例的`__proto__`仍然指向旧原型对象，因此访问不到在新原型里定义的方法：

```javascript
Person.prototype = {
    work: function () {
    	console.log('work function');   
    }
};
// 报错
wangwu.work(); // "wangwu.work is not a function"
// 在修改原型对象后创建的实例，因为获取到的__proto__属性是指向新原型的，因此不会报错
var sanma = new Person('三毛', 30);
// 可以愉快的“工作”
sanma.work(); // "work function"
```



![](http://xuh.cn-etc.com/2019/04/12/1555034405362.png)

覆盖整个原型对象后，相当于上面图中原来的prototype指向被切断了，指向了新的原型。



### 小结一下



默认情况下(因为原型对象实际上是可写的，因此可以被改变)：

> 1. 任何函数都有一个指向其原型对象的指针属性prototype;
>
> 2. 任何对象实例都有一个指向其构造函数原型对象的内部指针`[[Prototype]](__proto__)`；
> 3. 原型对象也是对象，因此也有`__proto__`(例如上图中指向Object.prototype那个);
> 4. 对象实例的`__proto__`指针指向构造函数的原型对象：`wangwu.__proto__ === Person.prototype `；
> 5. 原型对象的`constructor`属性指向构造函数： `Person.prototype.constructor === Person`；
> 6. 构造函数和对象实例没有直接联系，仅仅是都有一个指针属性指向同一个原型对象。



### 对象实例识别(检测)

我们知道，对于number、string、boolean、undefined、function这几种类型值，可以通过typeof操作符简单区分，但是对于除function外的引用类型实例和null，typeof都返回"object",但是再往细了区分，某个对象实例是神类型的实例，typeof就没办法了。



##### instanceof操作符

要识别具体的对象实例类型，就要用到instanceof操作符，格式为` instance instanceof Func`, instance是待检测实例对象，Func是一个构造函数，有了上面原型链的理解，那instanceof的检测机制就简单多了，只要在instance的原型链上某个`__proto__`指向了Func的原型对象，就返回true，否则返回false。即:

> `instance.__proto__...__proto__ === Func.prototype` 

另外也可以用Func.prototype.isPrototypeof(instance)、Object.getPrototypeof(instance) === Func.prototype来判断。

```javascript
console.log(wangwu instanceof Person); // true
console.log(wangwu instanceof Object); // true
console.log(Person.prototype.isPrototypeof(wangwu)); // true
console.log(Object.prototype.isPrototypeof(wangwu)); // true
console.log(Object.getPrototypeof(wangwu) === Person.prototype); // true
console.log(Object.getPrototypeof(wangwu) === Object.prototype); // false, 因为getPrototypeof函数只返回实例原型，而不会返回原型链上的其它原型
```



# 原型继承



