# Vivado 工程与 Vitis 工程仓库
## 项目目录
- ip_repo/ 负责读写 bram 模块的 ip 核模块
- vitis/ 使用的 vitis 生成目录 
- prj_gen.tcl： vivado 工程的生成脚本

由于 ZYNQ 采用手动连线形式，因此无法直接通过脚本完成整个工程的自动生成，脚本只是免去了寻找芯片型号的环节，生成内容仍需通过 create block 的形式创建并进行连线，使用教程参考《course_s2_ALINX_ZYNQ_MPSoC开发平台Vitis应用教程V1.06》第20章的相关内容。

## 用法
对于 vivado 工程，使用
```bash
vivado -mode batch -source prj_gen.tcl
```
命令自动生成工程。

在工程实现后，通过加载自定义 ip 核完成相关 ip 的加载，即 ip 仓库设置为 ip_repo/。

vitis 参考上述教程中《批处理建立 Vitis 工程》相关章节内容。
```
