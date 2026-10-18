# README.md
CUDAカーネル関数でアクセスできる整数ペア→somethingのマップです。配列のインデックスを使って直接アクセスする実装をしていて、O(1)でハッシュマップより高速です。インデックスの張る空間が大きすぎるとマップのメモリ使用量に注意を払う必要があります。
## build
実行する環境のGPUのCompute Capacityに合わせてオプション引数を指定する。(例: ver8.6のGPU)
```
cmake -S . -B build -DCMAKE_CUDA_ARCHITECTURES=86
cmake --build build
```