# Kabletop

The Kabletop project consists of Contracts and SDKs, currently limited to the Godot game engine and will scale to support Unity, CocosCreator and Unreal in the future. This demo will demonstrate a suitable example of using SDKs and contracts in order to implement a playable and innovative two-player card game, inspired by three titles: Slay the Spire, Magic The Gathering and Hearthstone Legends.

This demo is based on the Godot engine, and some experience with the engine (especially with Native) will be easier to follow.

Here's the Godot official website:
> https://godotengine.org/

Node：Kabletop is currently under development and not yet ready for release.

# Contracts

Kabletop contracts include NFT, Payment, Wallet and Kabletop. Currently they are all deployed on CKB Testnet. The SDK references them from a configuration file called Kableto.toml (https://github.com/ashuralyk/kabletop-demo/blob/master/Kabletop.toml#L7-L26), which stores connection and contract deployment information. Further details can be found in this repository: https://github.com/ashuralyk/kabletop-contracts.

# Relay Server

Due to NAT (Network Address Translation), Kabletop projects run generally in the intranet which made network penetration a problem. The relay server is there to solve the communication problem between clients in different internal networks.

Similar to the concept of server zones in traditional games, each relay server node resembles the zone of a Kabletop game. Different zones do not intersect with each other, but clients in the same zone, different descriptions can communicate with others, as long as they are connected to the same relay server.


# Kabletop SDK

Kabletop developers can import compiled dynamic link libraries such as `.dll`, `.dylib` and `.so` files directly into the Godot Engine.

The SDK is divided into two layers, [kabletop-ckb-sdk](https://github.com/ashuralyk/kabletop-ckb-sdk) and [kabletop-godot](https://github.com/ashuralyk/kabletop-godot):

1. `kabletop-ckb-sdk` is similar to a built-in Mercury service that provides some easy-to-use interfaces to build CKB transactions which are related to kabletop

2. `kabletop-godot` provides application-level code that can be recognized by Godot using gdnative and makes game developers be able to focus on just developing game logic instead of caring about how to interact with CKB contracts.

The SDK is still under development and has many imperfections. If modifications to the SDK are necessary, recompiling `kabletop-godot` and re-importing the resulting dynamic link library into Godot to replace the previous dynamic link library is feasible.

# Demo

This demo runs on the CKB Testnet. Specifically, the contracts are deployed on Testnet and the corresponding deployment information is written in the `Kabletop.toml` file that stores configurations of the demo. A default [private key](https://github.com/ashuralyk/kabletop-demo/blob/master/Kabletop.toml#L5) is contained in the `Kabletop.toml` file, but it is suggested to replace the private key with an own one before starting.

The Godot engine supports exporting its projects as executable files, so the demos can run directly in the editor or run through binary, making it possible to multiple demos on one machine. If any problems occur when running two demos on the same intranet, connecting to a relay server can be the solution.

The project contains both the GDScript code and the Lua code. The Lua code contains all of the game logic and has been compiled into binaries that are recognized by the Lua virtual machine that is already deployed on the CKB Testnet. Kabletop contract needs to reference the Lua code to validate the game logic on CKB network. Lua code is modifiable to meet users' needs. The modified version should be recompiled by `lua_recompiler` and be rewritten into [Kabletop.toml](https://github.com/ashuralyk/kabletop-demo/blob/master/Kabletop.toml#L24-L26) file to be redeployed to CKB.

The playing introduction can be found in [Wiki](https://github.com/cryptape/kabletop-demo/wiki/%5BCHN%5D-How-to-play-with-demo) and the released binary files covering all platforms are placed into [Releases](https://github.com/cryptape/kabletop-demo/releases). If there's any need to recompile SDK and run demo project in Godot engine, please following the steps below:
1. use `git clone https://github.com/cryptape/kabletop-demo --recursive` to clone demo project into native including submodules
2. use `cd kabletop-godot` to enter sdk directory
3. use `cargo build --release` to rebuild sdk project
4. copy generated dynamic file to replace the one in root directory:
> * windwos: copy targets/release/kabletop_godot.dll ..
> * linux: cp targets/release/libkabletop_godot.so ..
> * mac: cp targets/release/libkabletop_godot.dylib ..
5. download Godot engine and open `project.godot` file
6. run in Godot editor

Note: The art resources of the demo are all from "Slay the Spire" (Copyrights to [Mega Crit](https://www.megacrit.com)) and can only be used for learning and communication purposes, not for any commercial use.
