# PushkitDemo
# 仿微信收款语音提醒功能（在挂载的时候）

### 一.PushKit (这里用此方法，实现仿微信语音提醒功能-在后台)
 1).申请voip_services.cer, 开发生产环境都同一个证书。
 2).用了voip_services不需要用apns证书(一个voip证书搞定)，也不用再注册apns推送。
 3).PushKit的默认行为里面是不会弹出通知, 需要提示的话，本地通知推送。
 4).收到PushKit推送, 走AVSpeechSynthesisVoice系统自带TTS（这里采用本地离线语音合成）。
 5).APP挂载kill时，需要被唤起，加代码：AVAudioSessionCategoryPlayback。
 6).服务端PushMeBaby: https://github.com/stefanhafeneger/PushMeBaby。

### 二.参照：
1).微信iOS收款到账语音提醒开发总结：https://mp.weixin.qq.com/s/yYCaPMxHGT9LyRyAPewVWQ
2).iOS 8 pushkit使用总结：http://www.jianshu.com/p/5939dcb5fcd2
3).PushMeBaby的使用步骤:http://www.cnblogs.com/liuwj/p/6879382.html


One day，产品经理拿着微信二维码，演示一下微信的收款语言提醒，问我这个能实现吗？ 一看觉挺简单的，就着手调研。
大致思路：
 1.使用APNS推送；
 2.收到推送，使用苹果系统的TTS语言合成；
搜了很多资料，却发现在后台，或者APP杀死进程语言播报不出来，只能收到普通的推送；又继续查了很多相关资料，都是一些类似的废话，没说到重点。

### 方案一：APNS
使用APNS，收到推送本地播报语音（TTS生成的音频文件):用科大讯飞的免费的本地语音合成, 进行语音播报。
问题是解决了，但里边的原理逻辑还没弄明白，如果用苹果系统自带的本地离线语音合成才是正道，不用接第三SDK, 也可以减少包体积。
 
### 方案二：世人只知有APNS，却不知还有PushKit。
使用PushKit,收到推送使用系统自带的TTS(AVSpeechSynthesisVoice)进行语音播报，PushKit没有通知提醒，需要使用本地推送默认APNS效果。
微信的Bugly推送了一篇文章，#微信iOS收款到账语音提醒开发总结#提到了VoIP Push Notification，具体实现没提到，微信的实现用的是在线语音合成，试了下VoIP Push Notification还是实现不了后台语音播报，搜索了很多资料无果，进入死胡同。

 
 苹果系统最开始有：APP APNS, 接着iOS7推出了Silent Push， 到iOS8引入PushKit framework之后，APP就可以通过push随时唤醒了，暂时还只限于voip类应用。
 推送方式：
 1. Apple APNS:https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/
 2. Silent Push: http://hayageek.com/ios-silent-push-notifications
 3. PushKit
 
 
### 下面介绍下PushKit：
Question：PushKit是什么？
Answer:ios8苹果新引入了名为pushkit的框架和一种新的push通知类型，被称作voip push.该push方式旨在提供区别于普通apns push的能力，通过这种push方式可以使app执行制定的代码（在弹出通知给用户之前）；而该通知的默认行为和apns通知有所区别，它的默认行为里面是不会弹出通知的。目前来看PushKit的用途还局限于voip push(根据笔者的实战经验来看，其他类型的push暂时不能够起作用，sdk也正处于演进中)。

Question: PushKit能帮我们做什么？
Answer:PushKit中的voippush,可以帮助我们提升voip应用的体验，优化voip应用的开发实现，降低voip应用的电量消耗，它需要我们重新规划和设计我们的voip应用,从而得到更好的体验(voip push可以说是准实时的，实侧延时1秒左右)；苹果的目的是提供这样一种能力，可以让我们抛弃后台长连接的方案，也就是说应用程序通常不用维持和voip服务器的连接，在呼叫或者收到呼叫时，完成voip服务器的注册；当程序被杀死或者手机重启动时，都可以收到对方的来电，正常开展voip的业务。也就是说，我们当前可以利用它来优化voip的体验，增加接通率；条件成熟时我们就可以完全放弃后台的长连接，走到苹果为我们规划的道路上。
 对于pushkit，除了苹果framework官方文档：https://developer.apple.com/library/prerelease/ios/documentation/NetworkingInternet/Reference/PushKit_Framework/index.html#protocols 以外，能够找到的帮助理解PushKit的莫过于wwdc的视频：712_sd_writing_energy_efficient_code_part_2。该视频也可以从苹果官网下载。
 
### 使用push kit的优点 
 1.应用的voip长连接不保持，在收到呼叫或者发起呼叫时再连接；
 2.当呼叫发送到voip 服务器时，对端若不在线，通过voip 服务器连接到pushserver向对端发push通知；
 3.应用收到voip push通知时，迅速完成注册；
 4.呼叫方通过延时操作等逻辑（复杂一点对voip服务器进行改造，被叫连接上来以后通知到主叫侧），再次发起呼叫，通话即成功建立。
 
 
### 推送服务：
 1. PushMeBaby: https://github.com/stefanhafeneger/PushMeBaby
 2. NWPusher:https://github.com/noodlewerk/NWPusher

 
### 使用PushMeBaby需要注意
1.运行如果报错，那么导入CoreServices.framawork，替换这句 #include <CoreServices/../Frameworks/CarbonCore.framework/Headers/MacTypes.h>  为  #include <MacTypes.h>；
2.把你的开发证书.cer 文件更改名为apns.cer，放入工程中，代码中是通过；
 self.certificate = [[NSBundle mainBundle] pathForResource:@"apns" ofType:@"cer”];取你的证书文件的；
3.在输入框中粘贴进去你的deviceToken，注意不要带<>，空格可以有；
4.可以开心的测试了~

 
 
### 遇到的坑：
注册VoIPPushes，收不到token回调时，重启iphone设备就好了。
使用系统TTS播报，没有声音问题，服务端下发静默推送："content-available":1， eg:{"aps":{"alert":"收到语音推送","badge":1,"sound":"default","voiceOpen":1,"content-available":1}}


### 总结：
在调用过程中，走了很多弯路，钻过死胡同，差点就出不来了。讨论商量，集思广益，熟悉系统API, 关注WWDC非常重要，只要获取到一点点线索，都可能帮你发现新大陆，解决大问题。
