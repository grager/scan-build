#!/usr/bin/env bash

# RUN: bash %s %T/ignore_configure
# RUN: cd %T/ignore_configure; %{scan-build} -o . --intercept-first ./configure| ./check.sh
# RUN: cd %T/ignore_configure; %{scan-build} -o . --intercept-first  --override-compiler ./configure | ./check.sh
# RUN: cd %T/ignore_configure; %{scan-build} -o . --override-compiler ./configure | ./check.sh

set -o errexit
set -o nounset
set -o xtrace

# the test creates a subdirectory inside output dir.
#
# ${root_dir}
# ├── configure
# ├── check.sh
# └── src
#    └── broken.c

root_dir=$1
mkdir -p "${root_dir}/src"

cp "${test_input_dir}/div_zero.c" "${root_dir}/src/broken.c"

build_file="${root_dir}/configure"
cat >> "${build_file}" << EOF
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

\${CC} -c -o src/broken.o src/broken.c
true
EOF
chmod +x "${build_file}"

checker_file="${root_dir}/check.sh"
cat >> "${checker_file}" << EOF
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

out_dir=\$(sed -n 's/\(.*\) Report directory created: \(.*\)/\2/p')
if [ -d "\$out_dir" ]
then
    echo "output directory should not exists"
    false
fi
EOF
chmod +x "${checker_file}"