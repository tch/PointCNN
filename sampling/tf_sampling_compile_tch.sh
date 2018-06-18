#/bin/bash
PYTHON=python

CUDA_PATH=/usr/local/cuda
TF_LIB=$($PYTHON -c 'import tensorflow as tf; print(tf.sysconfig.get_lib())')
echo "tensorflow lib: $TF_LIB"

PYTHON_VERSION=$($PYTHON -c 'import sys; print("%d.%d"%(sys.version_info[0], sys.version_info[1]))')
TF_PATH="$TF_LIB/include"
echo "tensorflow inlude: $TF_PATH"

# see: https://github.com/tensorflow/tensorflow/issues/12482#issuecomment-328829250
NSYNC_PATH="/srv/shadow/opt/anaconda/envs/trackml/lib/python3.6/site-packages/"

nvcc -std=c++11 tf_sampling_g.cu -o tf_sampling_g.cu.o -c -O2 -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC -I $TF_PATH

#consider moving the below line into g++ command line
TF_CFLAGS=$($PYTHON -c 'import tensorflow as tf; print(" ".join(tf.sysconfig.get_compile_flags()))')
TF_LFLAGS=$($PYTHON -c 'import tensorflow as tf; print(" ".join(tf.sysconfig.get_link_flags()))')
echo "TF_CFLAGS: $TF_CFLAGS"
echo "TF_LFLAGS: $TF_LFLAGS"

#see: https://www.tensorflow.org/extend/adding_an_op
# note ..ABI=1

g++ -shared -std=c++11 tf_sampling.cpp tf_sampling_g.cu.o -o tf_sampling_so.so -fPIC -L$TF_LIB -ltensorflow_framework -I $NSYNC_PATH/external/nsync/public/ -I$TF_PATH -I$CUDA_PATH/include -lcudart -L $CUDA_PATH/lib64/ -O2 -D_GLIBCXX_USE_CXX11_ABI=1
