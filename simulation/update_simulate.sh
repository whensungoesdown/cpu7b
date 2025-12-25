#!/bin/bash

# 获取当前目录
current_dir=$(pwd)

# 获取test0目录中的simulate.sh路径
source_file="test0/simulate.sh"

# 检查源文件是否存在
if [ ! -f "$source_file" ]; then
    echo "错误: 找不到源文件 $source_file"
    exit 1
fi

echo "开始更新所有test目录的simulate.sh文件..."
echo "源文件: $source_file"
echo ""

# 查找所有test开头的目录
for dir in test*/ ; do
    # 移除目录名末尾的斜杠
    dir=${dir%/}
    
    # 跳过test0目录本身（因为是源文件）
    if [ "$dir" = "test0" ]; then
        echo "跳过源目录: $dir"
        continue
    fi
    
    # 检查目标目录是否存在
    if [ ! -d "$dir" ]; then
        echo "警告: 目录 $dir 不存在，跳过"
        continue
    fi
    
    echo "处理目录: $dir"
    
    # 复制simulate.sh文件
    echo "  复制 simulate.sh 到 $dir/"
    cp "$source_file" "$dir/simulate.sh"
    
    # 替换文件中的test0_top_tb.v为目录名_top_tb.v
    echo "  替换 test0_top_tb.v 为 ${dir}_top_tb.v"
    sed -i "s|test0_top_tb\.v|${dir}_top_tb.v|g" "$dir/simulate.sh"
    
    # 为了更精确，可以同时检查并替换可能的其他test0引用
    # 检查文件中是否还有test0_top_tb.v
    if grep -q "test0_top_tb.v" "$dir/simulate.sh"; then
        echo "  警告: $dir/simulate.sh 中仍然存在 test0_top_tb.v 的引用"
    fi
    
    # 验证替换结果
    echo "  验证替换结果:"
    if grep -q "${dir}_top_tb.v" "$dir/simulate.sh"; then
        echo "    ✓ 找到 ${dir}_top_tb.v"
    else
        echo "    ✗ 未找到 ${dir}_top_tb.v，替换可能失败"
    fi
    
    echo ""
done

echo "所有test目录的simulate.sh文件更新完成！"
echo ""
echo "更新结果示例:"
echo "原行: vlog +incdir+../../rtl +incdir+../../rtl/c7bbiu -f ../../flist/sim.files ../../tb/test0_top_tb.v"
echo "新行: vlog +incdir+../../rtl +incdir+../../rtl/c7bbiu -f ../../flist/sim.files ../../tb/test1_ld.w_top_tb.v"
