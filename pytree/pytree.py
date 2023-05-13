import argparse
import ast
from pathlib import Path


def get_imports(path):
    with open(path) as f:
        root = ast.parse(f.read(), path)

    for node in ast.iter_child_nodes(root):
        if isinstance(node, ast.Import):
            for alias in node.names:
                yield alias.name
        elif isinstance(node, ast.ImportFrom):
            for alias in node.names:
                yield node.module + "." + alias.name


def get_local_modules(root_path):
    local_modules = set()

    for path in root_path.rglob('*.py'):
        module_path = path.relative_to(root_path).with_suffix('')
        module_name = '.'.join(module_path.parts)
        local_modules.add(module_name)

    return local_modules


def build_dependency_tree(path, root_path, seen=None, current_branch=None, circular_deps=None):
    path = Path(path)
    if seen is None:
        seen = {path.stem: {}}
    if current_branch is None:
        current_branch = set()
    if circular_deps is None:
        circular_deps = set()

    local_modules = get_local_modules(root_path)
    imports = list(dict.fromkeys(get_imports(path)))

    for i, module in enumerate(imports):
        if "." in module:
            module = module.split(".")[0]

        if module in local_modules:
            if module in current_branch:
                circular_dep = (path.stem, module)
                if circular_dep not in circular_deps:
                    print(
                        "\033[31m"
                        + f"Circular dependency! Skipping: {circular_dep[0]}.py <> {circular_dep[1]}.py"
                        + "\033[0m"
                    )
                    circular_deps.add(circular_dep)
                continue

            current_branch.add(module)
            seen[path.stem][module] = {}
            build_dependency_tree(
                path.parent / (module + ".py"),
                root_path,
                seen[path.stem],
                current_branch,
                circular_deps,
            )
            current_branch.remove(module)

    return seen



def print_dependency_tree(tree, indent="", is_root=True):
    for i, (module, sub_tree) in enumerate(tree.items()):
        is_last = i == len(tree) - 1
        if not is_root:
            branch = "└── " if is_last else "├── "
            print(indent + branch + module + ".py")
        else:
            print(module + ".py")
        print_dependency_tree(
            sub_tree,
            indent + ("" if is_root else ("    " if is_last else "│   ")),
            is_root=False,
        )


def main():
    parser = argparse.ArgumentParser(
        description="Print the local module dependency tree of a Python file."
    )
    parser.add_argument("file", help="Your python file")

    args = parser.parse_args()

    root_path = Path(args.file).parent
    dependency_tree = build_dependency_tree(args.file, root_path)

    print_dependency_tree(dependency_tree)


if __name__ == "__main__":
    main()
