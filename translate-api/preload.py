import argostranslate.package
import argostranslate.translate

languages = ["en", "zh", "ja", "es"]

# Download and install Argos Translate packages for all language pairs
argostranslate.package.update_package_index()
available_packages = argostranslate.package.get_available_packages()
print("Languages available: {available_packages}")

for from_code in languages:
    for to_code in languages:
        if from_code == to_code:
            continue
        package = next(
            (pkg for pkg in available_packages if pkg.from_code == from_code and pkg.to_code == to_code),
            None
        )
        if package:
            print(f"Installing package: {from_code} to {to_code}")
            argostranslate.package.install_from_path(package.download())