# 🎮 星尘谱系 · Stellar Pedigree

一款2D俯视角Roguelite射击游戏，使用Godot 4开发。

## 游戏概述

- **类型**：2D俯视角Roguelite射击游戏
- **平台**：Windows (.exe)
- **核心体验**：操控飞船在星空中战斗，通过随机升级组合强力Build，击败最终BOSS
- **开发阶段**：开发中

## 技术栈

- **引擎**：Godot 4.2+
- **语言**：GDScript
- **版本控制**：Git + GitHub
- **CI/CD**：GitHub Actions

## 项目结构

```
Stellar-Pedigree/
├── src/
│   ├── scripts/          # 脚本文件
│   │   ├── player/       # 玩家相关
│   │   ├── weapons/      # 武器系统
│   │   ├── enemies/      # 敌人AI
│   │   ├── rooms/        # 房间系统
│   │   └── ui/           # 用户界面
│   ├── scenes/           # 场景文件
│   │   ├── player/
│   │   ├── weapons/
│   │   ├── enemies/
│   │   └── ui/
│   └── resources/        # 资源文件
│       ├── weapon_data/
│       ├── enemy_data/
│       └── upgrade_data/
├── .github/workflows/    # CI/CD配置
├── docs/                 # 文档
└── README.md
```

## 开发计划

### 第一阶段：核心基础
- [x] 项目初始化
- [ ] 玩家控制器（WASD移动+鼠标射击）
- [ ] 基础武器系统（5种MVP武器）
- [ ] 基础敌人AI（3种小怪）

### 第二阶段：核心玩法
- [ ] 房间系统和关卡生成
- [ ] 经验系统和升级界面
- [ ] BOSS系统
- [ ] UI界面完善

### 第三阶段：内容扩展
- [ ] 视觉效果和粒子特效
- [ ] 永久解锁系统
- [ ] 完整内容扩展
- [ ] 性能优化和打包

## 控制说明

- **移动**：WASD
- **射击**：鼠标方向自动连射
- **升级界面**：Esc暂停，选择升级

## 开发说明

每个功能完成后进行测试，确保稳定性后再进行下一步开发。

## 许可证

MIT License
