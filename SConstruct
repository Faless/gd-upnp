#!python

import os, sys, platform, json, subprocess

import SCons

env = SConscript("godot-cpp/SConstruct").Clone()

opts = Variables(["customs.py"], ARGUMENTS)
opts.Add(BoolVariable("builtin_miniupnpc", "Use the built-in miniupnpc library", True))
opts.Update(env)

result_path = os.path.join("bin", "gdupnp")

# Our includes and sources
env.Append(CPPDEFINES=["GDEXTENSION"])  # Tells our sources we are building a GDExtension, not a module.
sources = [
    "src/register_types.cpp",
    "src/upnp.cpp",
    "src/upnp_device.cpp",
]

# Documentation
if env["target"] in ["editor", "template_debug"]:
    doc_data = env.GodotCPPDocData("src/gen/doc_data.gen.cpp", source=Glob("doc_classes/*.xml"))
    sources.append(doc_data)

# Thirdparty sources
thirdparty_sources = []

if env["builtin_miniupnpc"]:
    thirdparty_dir = "#thirdparty/miniupnp/miniupnpc/"
    thirdparty_sources = [
        "igd_desc_parse.c",
        "miniupnpc.c",
        "minixml.c",
        "minisoap.c",
        "minissdpc.c",
        "miniwget.c",
        "upnpcommands.c",
        "upnpdev.c",
        "upnpreplyparse.c",
        "connecthostport.c",
        "portlistingparse.c",
        "receivedata.c",
        "addr_is_reserved.c",
    ]
    thirdparty_sources = [thirdparty_dir + "src/" + file for file in thirdparty_sources]

    env.Prepend(CPPPATH=["src/thirdparty/miniupnpc"])
    env.Prepend(CPPPATH=[thirdparty_dir + "include"])
    env.Append(CPPDEFINES=["MINIUPNP_STATICLIB"])
    if env["platform"] != "windows":
        env.Append(CPPDEFINES=["MINIUPNPC_SET_SOCKET_TIMEOUT"])

sources += thirdparty_sources

# We want to statically link against libstdc++ on Linux to maximize compatibility, but we must restrict the exported
# symbols using a GCC version script, or we might end up overriding symbols from other libraries.
# Using "-fvisibility=hidden" will not work, since libstdc++ explicitly exports its symbols.
symbols_file = None
if env["platform"] == "linux" or (
    env["platform"] == "windows" and env.get("use_mingw", False) and not env.get("use_llvm", False)
):
    symbols_file = env.File("misc/gcc/symbols-extension.map")
    env.Append(
        LINKFLAGS=[
            "-Wl,--no-undefined,--version-script=" + symbols_file.abspath,
            "-static-libgcc",
            "-static-libstdc++",
        ]
    )
    env.Depends(sources, symbols_file)

# Windows libraries
if env["platform"] == "windows":
    env.Append(LIBS=["ws2_32", "iphlpapi"])

# Make the shared library
result_name = "libgdupnp{}{}".format(env["suffix"], env["SHLIBSUFFIX"])

if env["platform"] in ["macos", "ios"]:
    framework_path = os.path.join(
        result_path, "lib", "libgdupnp.{}.{}.{}.framework".format(env["target"], env["platform"], env["arch"])
    )
    library_file = env.SharedLibrary(target=os.path.join(framework_path, result_name), source=sources)
    plist_file = env.Substfile(
        os.path.join(framework_path, "Resources", "Info.plist"),
        "misc/dist/{}/Info.plist".format(env["platform"]),
        SUBST_DICT={"{LIBRARY_NAME}": result_name, "{DISPLAY_NAME}": "libgdupnp" + env["suffix"]},
    )
    library = [library_file, plist_file]
else:
    library = env.SharedLibrary(target=os.path.join(result_path, "lib", result_name), source=sources)

Default(library)

# GDNativeLibrary
extfile = env.InstallAs(os.path.join(result_path, "gdupnp.gdextension"), "misc/gdupnp.gdextension")
Default(extfile)
