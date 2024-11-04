#!python

import os, sys, platform, json, subprocess

import SCons

env = SConscript("godot-cpp/SConstruct").Clone()

opts = Variables(["customs.py"], ARGUMENTS)
opts.Add(BoolVariable("builtin_miniupnpc", "Use the built-in miniupnpc library", True))
opts.Update(env)

result_path = os.path.join("bin", "gdupnp")

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

# Our includes and sources
env.Append(CPPDEFINES=["GDEXTENSION"])  # Tells our sources we are building a GDExtension, not a module.
sources = [
    "src/register_types.cpp",
    "src/upnp.cpp",
    "src/upnp_device.cpp",
]

sources += thirdparty_sources

# Windows libraries
if env["platform"] == "windows":
    env.Append(LIBS=["ws2_32", "iphlpapi"])

# Make the shared library
result_name = "gdupnp{}{}".format(env["suffix"], env["SHLIBSUFFIX"])
library = env.SharedLibrary(target=os.path.join(result_path, "lib", result_name), source=sources)

Default(library)

# GDNativeLibrary
extfile = env.InstallAs(os.path.join(result_path, "gdupnp.gdextension"), "misc/gdupnp.gdextension")
Default(extfile)
