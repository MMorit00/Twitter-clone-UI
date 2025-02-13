import os

def merge_swift_files(directory_path, output_file, subfolders=None):
    # 确保输出文件的目录存在
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    # 用于存储所有找到的 swift 文件
    swift_files = []
    
    # 遍历目录
    for root, dirs, files in os.walk(directory_path):
        # 如果指定了子文件夹，检查当前目录是否在指定的子文件夹中
        if subfolders:
            relative_path = os.path.relpath(root, directory_path)
            if relative_path == '.' or not any(relative_path.startswith(subfolder) for subfolder in subfolders):
                continue
        
        for file in files:
            if file.endswith('.swift'):
                full_path = os.path.join(root, file)
                if os.path.abspath(full_path) != os.path.abspath(output_file):
                    swift_files.append(full_path)
    
    # 按文件名排序，使输出更有序
    swift_files.sort()
    
    # 如果输出文件已存在，直接覆盖
    with open(output_file, 'w', encoding='utf-8') as outfile:
        outfile.write("// Merged Swift Files\n\n")
        
        for swift_file in swift_files:
            relative_path = os.path.relpath(swift_file, directory_path)
            outfile.write(f"\n// MARK: - {relative_path}\n\n")
            
            with open(swift_file, 'r', encoding='utf-8') as infile:
                outfile.write(infile.read())
            outfile.write("\n")

if __name__ == "__main__":
    # 固定源目录和输出文件路径
    source_directory = "/Users/panlingchuan/Downloads/My Project/Twitter-clone/Sources"
    output_path = "/Users/panlingchuan/Downloads/My Project/Twitter-clone/merged_code.swift"
    
    # 获取用户输入的子文件夹
    print("请输入要合并的子文件夹名称（多个文件夹用空格分隔，直接回车则合并所有文件）：")
    subfolder_input = input().strip()
    subfolders = subfolder_input.split() if subfolder_input else None
    
    # 执行合并
    merge_swift_files(source_directory, output_path, subfolders)
    print(f"合并完成！输出文件: {output_path}")