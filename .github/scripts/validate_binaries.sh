if [[ ${MATRIX_PACKAGE_TYPE} == "libtorch" ]]; then
    curl ${MATRIX_INSTALLATION} -o libtorch.zip
    unzip libtorch.zip
else
    if [ $MATRIX_PYTHON_VERSION == '3.11' ]; then
        export CPYTHON_VERSIONS=3.11.0
        sudo yum -y install openssl-devel libssl-dev bzip2-devel libffi-devel
        sudo yum -y groupinstall "Development Tools"
        export PYTHON_PATH="/opt/_internal/cpython-3.11.0/bin"
        export PIP_PATH="${PYTHON_PATH}/pip"
        export PIP_INSTALLATION="${MATRIX_INSTALLATION/pip3/"$PIP_PATH"}"
        export WITH_OPENSSL="/opt/openssl"
        ./common/install_cpython.sh
        eval ${PYTHON_PATH}/python --version
        eval ${PIP_INSTALLATION}
        eval ${PYTHON_PATH}/python ./test/smoke_test/smoke_test.py --package torchonly
    else
        conda create -y -n ${ENV_NAME} python=${MATRIX_PYTHON_VERSION} numpy pillow
        conda activate ${ENV_NAME}
        INSTALLATION=${MATRIX_INSTALLATION/"conda install"/"conda install -y"}
        eval $INSTALLATION

        if [[ ${TARGET_OS} == 'linux' ]]; then
            export CONDA_LIBRARY_PATH="$(dirname $(which python))/../lib"
            export LD_LIBRARY_PATH=$CONDA_LIBRARY_PATH:$LD_LIBRARY_PATH
            ${PWD}/check_binary.sh
        fi

        python  ./test/smoke_test/smoke_test.py
    fi
fi
