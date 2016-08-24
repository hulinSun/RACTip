# RACTip
RAC学习笔记

###链式编程思想

```objc

//1. 简单的链式调用
    Hony *hony = [[Hony alloc]init];
    hony.shopping().eating();
    
//2. 带有参数
    Hony *hony = [[Hony alloc]init];
    // 是不是越来有masonry 的意思了
    hony.call(@"老公").takeOff(@"bar...");

//3. 复杂的链式调用
UIView *view = [[UIView alloc]init];
    [view cm_configMaker:^(ConfigMaker *make) {
     make.bgColor([UIColor redColor])
         .coreRadius(@50)
         .frame([NSValue valueWithCGRect:CGRectMake(100, 100, 100, 100)]);
    }];
```

###HOOK思想

*  运用的是Hook（钩子）思想，Hook是一种用于改变API(应用程序编程接口：方法)执行结果的技术.
*  Hook用处：截获API调用的技术。
*  Hook原理：在每次调用一个API返回结果之前，先执行你自己的方法，改变结果的输出。

###函数式编程思想
 *  把操作尽量写成一系列嵌套的函数或者方法调用
 *  链式编程
 *  ReactiveCocoa被描述为函数响应式编程（FRP）框架(核心是信号)
 
 *  可以把信号想象成水龙头，只不过里面不是水，而是玻璃球(value)，直径跟水管的内径一样，这样就能保证玻璃球是依次排列，不会出现并排的情况(数据都是线性处理的，不会出现并发情况)。水龙头的开关默认是关的，除非有了接收方(subscriber)，才会打开。这样只要有新的玻璃球进来，就会自动传送给接收方。可以在水龙头上加一个过滤嘴(filter)，不符合的不让通过，也可以加一个改动装置，把球改变成符合自己的需求(map)。也可以把多个水龙头合并成一个新的水龙头(combineLatest:reduce:)，这样只要其中的一个水龙头有玻璃球出来，这个新合并的水龙头就会得到这个球
 
 *   函数组合之后仍然是个函数，所以也很容易理解两个Stream对象的组合其实就是生成一个新的Stream对象，它返回了分别由两个子Stream先后运算产生的最终结果 --> 函数式编程

``` 
像解函数一样编程
f1(x) = 2x + 1 ==> 求f1(2);
f2(x) = x -4; ==> f2(3);
f3(x) = 3x + 5 ==> f3(2) 
求 f1(f3(f2(3)))的值
```

###ReactiveCocoa 常用类

**RACSiganl 信号类。**

* RACEmptySignal ：空信号，用来实现  RACSignal 的 +empty 方法；
* RACReturnSignal ：一元信号，用来实现 RACSignal 的 +return: 方法；
* RACDynamicSignal ：动态信号，使用一个 block - 来实现订阅行为，我们在使用 RACSignal 的 +createSignal: 方法时创建的就是该类的实例；
* RACErrorSignal ：错误信号，用来实现 RACSignal 的 +error: 方法；
* RACChannelTerminal ：通道终端，代表 RACChannel 的一个终端，用来实现双向绑定。


**RACSubscriber 订阅者**

**RACDisposable 用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。**

* RACSerialDisposable ：作为 disposable 的容器使用，可以包含一个 disposable 对象，并且允许将这个 disposable 对象通过原子操作交换出来；
* RACKVOTrampoline ：代表一次 KVO 观察，并且可以用来停止观察；
* RACCompoundDisposable ：它可以包含多个 disposable 对象，并且支持手动添加和移除 disposable 对象
* RACScopedDisposable ：当它被 dealloc 的时候调用本身的 -dispose 方法。

**RACSubject 信号提供者，自己可以充当信号，又能发送信号。订阅后发送**

* RACGroupedSignal ：分组信号，用来实现 RACSignal 的分组功能；
* RACBehaviorSubject ：重演最后值的信号，当被订阅时，会向订阅者发送它最后接收到的值；
* RACReplaySubject ：重演信号，保存发送过的值，当被订阅时，会向订阅者重新发送这些值。可以先发送后订阅

**RACTuple 元组类,类似NSArray,用来包装值.**

**RACSequence RAC中的集合类**

**RACCommand RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程。**

**RACMulticastConnection 用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。**

**RACScheduler RAC中的队列，用GCD封装的。**

### 替代Target—action 代理 kvo 通知等响应方法

* rac_signalForSelector : 代替代理
* rac_valuesAndChangesForKeyPath: KVO
* rac_signalForControlEvents:监听事件
* rac_addObserverForName 代替通知
* rac_textSignal：监听文本框文字改变

###信号操作方法

* flattenMap 扁平化映射，把源信号的内容映射成一个新的信号，信号可以是任意类型
*  map 用于把源信号内容映射成新的内容。
* concat 组合 按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号
* then 用于连接两个信号，当第一个信号完成，才会连接then返回的信号。
* merge 把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
* zipWith 把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
* combineLatest:将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
* reduce聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
* filter:过滤信号，使用它可以获取满足条件的信号.
* ignore:忽略完某些值的信号.
* distinctUntilChanged:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
* take:从开始一共取N次的信号
* takeLast:取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号.
* takeUntil:(RACSignal *):获取信号直到某个信号执行完成
* skip:(NSUInteger):跳过几个信号,不接受。
* switchToLatest:用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。
* doNext: 执行Next之前，会先执行这个Block
* doCompleted: 执行sendCompleted之前，会先执行这个Block
* timeout：超时，可以让一个信号在一定的时间后，自动报错。
* interval 定时：每隔一段时间发出信号
* delay 延迟发送next。
* retry重试 ：只要失败，就会重新执行创建信号中的block,直到成功.
* replay重放：当一个信号被多次订阅,反复播放内容
* throttle节流:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出
*  deliverOn: 内容传递切换到制定线程中，副作用在原来线程中,把在创建信号时block中的代码称之为副作用。
 * subscribeOn: 内容传递和副作用都会切换到制定线程中。


###RAC 宏

* RAC(TARGET, [KEYPATH, [NIL_VALUE]])：用于给某个对象的某个属性绑定
* RACObserve(self, name) ：监听某个对象的某个属性,返回的是信号。
* weakify(Obj)和strongify(Obj)
* RACTuplePack ：把数据包装成RACTuple（元组类）
* RACTupleUnpack：把RACTuple（元组类）解包成对应的数据

**参考链接：**<http://www.jianshu.com/p/01546347bad5>,
<http://blog.sunnyxx.com/2014/03/06/rac_3_racsignal/>,
<http://limboy.me/tech/2013/06/19/frp-reactivecocoa.html>