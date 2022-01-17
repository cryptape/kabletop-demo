# Kabletop

Kabletop 项目由 Contracts 和 SDK 组成，SDK 目前只支持 Godot 游戏引擎，未来还将拓展对 Unity、Cocoscreator 和 Unreal 的支持。本 Demo 旨在如果使用 SDK 和 Contracts 上给出一个比较合适的使用范例，该范例实现了一个具备一定可玩性和创新性的双人卡牌对战游戏，在制作上参考了《杀戮尖塔》、《万智牌》和《炉石传说》这三款游戏。

本 Demo 基于 GodotEngine 制作，所以如果具备一定的引擎使用经验（尤其是和 Native 相关）将会更容易上手。Godot 引擎相关信息可在官网查阅：
> https://godotengine.org/

<b>注：Kabletop 目前还处于开发阶段，不能用于生产环境。</b>

# Contracts

Kabletop 包含 4 个合约，分别为NFT、Payment、Wallet 和 Kabletop，当前合约部署在 Testnet 上，SDK 通过在配置文件 <a href="https://github.com/ashuralyk/kabletop-demo/blob/master/Kabletop.toml#L12-L30">Kabletop.toml</a> 中添加合约的部署信息去引用这些合约。合约的详细信息可在合约仓库中查看：
> https://github.com/ashuralyk/kabletop-contracts

# Relay Server

由于 NAT 方面的原因，Kabletop 的项目一般都在内网环境中运行，所以网络穿透将会是个麻烦的问题，这便是 RelayServer 存在的原因：解决不同内网环境下的客户端的通信问题。

类似于传统游戏中区服的概念，每一个 RelayServer 节点就像是一个 Kabletop 游戏的区服，各个区服之间没有交集，同一区服下的客户端可以互相通信。

# Kabletop SDK

Kabletop 的开发者可以将编译好的动态连接库（dll、dylib、so）直接导入到 Godot 游戏引擎中使用，使用方式参考 Godot 官方教程或查看 Demo 实现方式。

SDK 还处在开发阶段，还有很多不完善的地方，如果需要自己修改 SDK 代码，可以在修改代码后重新编译 <a href="#">kabletop-godot</a> 项目，取出编译好的动态链接库导入到项目中即可。

SDK 分为两个层次，由 <a href="#">kabletop-ckb-sdk</a> 和 <a href="">kabletop-godot</a> 组成。第一个层次类似于一个内建的 Mercury 服务，通过提供一系列简易的接口来构建与 Kabletop 相关的 CKB 交易，第二个层次通过集成 <a href="https://docs.rs/gdnative/latest/gdnative/">gdnative</a> 来提供能被 Godot 游戏引擎识别的应用层代码，使游戏开发者能集中精力编写游戏逻辑代码而不用关心如何与 CKB 合约交互。

# Demo

Demo 的美术资源全部来自《杀戮尖塔》，只能用于学习和交流使用，不可用于任何商业用途。

本 Demo 运行在测试网上，已在配置文件中配置了一把默认的<a href="https://github.com/ashuralyk/kabletop-demo/blob/master/Kabletop.toml#L7">私钥</a>，但建议在体验 Demo 的时候最好将它替换成自己的私钥。

Godot 引擎支持导出功能，本 Demo 可以直接在 Godot 编辑器中运行，也可以导出后运行，导出运行需要将关联的动态链接库文件和 Kabletop.toml 配置文件放在和导出文件相同的目录下。

开启两个具备不同私钥的 Demo 后即可开始对战，如果两个 Demo 不在同一个局域网下，还可以通过连接 RelayServer 来开启对战。