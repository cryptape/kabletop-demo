# Kabletop

The Kabletop project consists of Contracts and SDKs, which currently only support the Godot game engine and will be expanded to support Unity, Cocoscreator and Unreal. This demo aims to give an example of a suitable use of the SDK and Contracts, which implements a playable and innovative two-player card game with reference to three games: Slay the Spire, Magic The Gathering and Hearthstone Legends.

This demo is based on the Godot Engine, so if you have some experience with the engine (especially with Native), it will be easier to get started.

Here's the Godot official website:
> https://godotengine.org/

<b>Node：Kabletop is currently on development stage, and not ready for production release.</b>

# Contracts

Kabletop contracts consist of NFT, Payment, Wallet and Kabletop seperately which are currently deployed on CKB Testnet. The SDK references them from configuration file named <a href="https://github.com/ashuralyk/kabletop-demo/blob/master/Kabletop.toml#L7-L26">Kabletop.toml</a> where stores connection and contract deployment information. Concrete details can be found from the repository below:
> https://github.com/ashuralyk/kabletop-contracts

# Relay Server

For NAT reasons, kabletop projects generally run in the intranet which made network penetration be a problem, so this is exactly why relay server exists: to solve the communication problem of clients in different intranet.

Similar to the concept of server zones in traditional games, each relay server node is like a zone of a kabletop game. There is no intersection between the different zones, but clients in the same zone, which is a deferent description of connecting to the same relay server, can communicate with others.

# Kabletop SDK

Kabletop developers can import compiled dynamic link libraries like .dll, .dylib and .so file directly into the Godot Engine.

The SDK is divided into two layers which are seperately <a href="https://github.com/ashuralyk/kabletop-ckb-sdk">kabletop-ckb-sdk</a> and <a href="https://github.com/ashuralyk/kabletop-godot">kabletop-godot</a>:

1. kabletop-ckb-sdk is similar to a built-in Mercury service that provides some easy-to-use interfaces to build CKB transactions which are related to kabletop

2. kabletop-godot provides application-level code that can be recognized by Godot using gdnative and makes game developers be able to focus on just developing game logic instead of caring about how to interact with CKB contracts.

The SDK is still in the development stage, there are still many imperfections, if modifying SDK is necessary, recompiling <b>kabletop-godot</b> and reimporting the generated dynamic link library into Godot to replace the previous one is working.

# Demo

This demo is running on CKB Testnet, for specific, contracts are deployed on Testnet and corresponding deployment information is writen in the Kabletop.toml file where stores configurations for demo. A default <a href="https://github.com/ashuralyk/kabletop-demo/blob/master/Kabletop.toml#L5">private key</a> has been placed into Kabletop.toml, but it is recommended to replace it with your own private key before you start to experience.

The Godot engine supports to export its project into executable file, so the demo can be directly run in editor, or just run through binary which makes it possible to run more than one demo on one machine. If there is any problem to run two demos on the same intranet, letting them connect to the relay server could solve.

Project contains both GDScript code and Lua code where Lua code contains all the gameplay logic and is already deployed on the CKB Testnet after compiling into binary which Lua virtual machine could recognize. Kabletop contract needs to reference Lua code to validate the gameplay logic on CKB network. If there is any requirement to modify the Lua code, after modifying, developer can use <a href="https://github.com/ashuralyk/lua_recompiler">lua_recompiler</a> to recompile and deploy, but the lasted deployment information of Lua code should rewrite into <a href="https://github.com/ashuralyk/kabletop-demo/blob/master/Kabletop.toml#L24-L26">Kabletop.toml</a> file.

<b>Note: The art resources of the demo are all from "Slay the Spire" and can only be used for learning and communication purposes, not for any commercial use.</b>