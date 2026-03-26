from mp_api.client import MPRester

# 将 YOUR_API_KEY 替换为您在官网获取的真实秘钥
api_key = "NqbvBekB6TBXn9dG5smLjaAJhx9fwkPG"
material_id = "mp-" + input("输入ID：") # 以锐钛矿 TiO2 为例

# 连接到 MP 数据库
with MPRester(api_key) as mpr:
    # 获取材料结构 (默认获取的是 conventional standard structure)
    structure = mpr.get_structure_by_material_id(material_id)
    
    # 将结构对象导出为 CIF 文件
    import os
    output_dir = os.path.join(os.path.dirname(__file__), "All_CIFs")
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    filename = os.path.join(output_dir, f"{material_id}.cif")
    structure.to(fmt="cif", filename=filename)
    
    print(f"成功下载 {material_id} 的 CIF 文件并保存为 {filename}")
