#!/usr/bin/env bash

# RUN: bash %s %T/extend_build
# RUN: cd %T/extend_build; %{intercept-build} --cdb result.json ./run-one.sh
# RUN: cd %T/extend_build; cdb_diff result.json one.json
# RUN: cd %T/extend_build; %{intercept-build} --cdb result.json ./run-two.sh
# RUN: cd %T/extend_build; cdb_diff result.json two.json
# RUN: cd %T/extend_build; %{intercept-build} --cdb result.json --append ./run-one.sh
# RUN: cd %T/extend_build; cdb_diff result.json sum.json

set -o errexit
set -o nounset
set -o xtrace

# the test creates a subdirectory inside output dir.
#
# ${root_dir}
# ├── run-one.sh
# ├── run-two.sh
# ├── one.json
# ├── two.json
# ├── sum.json
# └── src
#    └── empty.c

root_dir=$1
mkdir -p "${root_dir}/src"

touch "${root_dir}/src/empty.c"

build_file="${root_dir}/run-one.sh"
cat >> ${build_file} << EOF
#!/usr/bin/env bash

set -o nounset
set -o xtrace

"\$CC" -c -o src/empty.o -Dver=1 src/empty.c;
"\$CXX" -c -o src/empty.o -Dver=2 src/empty.c;

true;
EOF
chmod +x ${build_file}

build_file="${root_dir}/run-two.sh"
cat >> ${build_file} << EOF
#!/usr/bin/env bash

set -o nounset
set -o xtrace

cd src
"\$CC" -c -o empty.o -Dver=3 empty.c;
"\$CXX" -c -o empty.o -Dver=4 empty.c;

true;
EOF
chmod +x ${build_file}

cat >> "${root_dir}/one.json" << EOF
[
{
  "command": "cc -c -o src/empty.o -Dver=1 src/empty.c",
  "directory": "${root_dir}",
  "file": "src/empty.c"
}
,
{
  "command": "c++ -c -o src/empty.o -Dver=2 src/empty.c",
  "directory": "${root_dir}",
  "file": "src/empty.c"
}
]
EOF

cat >> "${root_dir}/two.json" << EOF
[
{
  "command": "cc -c -o empty.o -Dver=3 empty.c",
  "directory": "${root_dir}/src",
  "file": "empty.c"
}
,
{
  "command": "c++ -c -o empty.o -Dver=4 empty.c",
  "directory": "${root_dir}/src",
  "file": "empty.c"
}
]
EOF

cat >> "${root_dir}/sum.json" << EOF
[
{
  "command": "cc -c -o src/empty.o -Dver=1 src/empty.c",
  "directory": "${root_dir}",
  "file": "src/empty.c"
}
,
{
  "command": "c++ -c -o src/empty.o -Dver=2 src/empty.c",
  "directory": "${root_dir}",
  "file": "src/empty.c"
}
,
{
  "command": "cc -c -o empty.o -Dver=3 empty.c",
  "directory": "${root_dir}/src",
  "file": "empty.c"
}
,
{
  "command": "c++ -c -o empty.o -Dver=4 empty.c",
  "directory": "${root_dir}/src",
  "file": "empty.c"
}
]
EOF
