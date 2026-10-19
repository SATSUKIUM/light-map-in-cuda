#include <cuda_runtime.h>
#include <stdio.h>
#include <iostream>

#include <chrono>
#include <iomanip>

#include <string>
#include <sstream>

#include <vector>

#include <cstdlib>
#include <iostream>
#include <limits>

#include "cudamap.h"

// forward declaration of the kernel function
__global__ void doWarmUp();

__global__ void testDecoder(const cudamap::FEEAddrDecoder* decoder)
{
    printf("testDecoder called\n");
    uint32_t key;

    // test getKey and getTriggerConfig
    if (decoder->getKey(0xc0, 0xa8, 0x02, 0xa9, 8, key)) { // for 192.168.2.169, ch 8
        printf("%d, %d, %d, %d, %d -> key=%u\n", 0xc0, 0xa8, 0x02, 0xa9, 8, key);
        auto config = decoder->getTriggerConfig(key);
        printf("\tkey=%u: iSubTimeRegion=%u hitBit=%u delay=%u width=%u\n", key, config.iSubTimeRegion, config.hitBit, config.delay, config.width);
    }
    else {
        printf("Failed to get key for 192.168.2.169, ch 8\n");
    }

    if(decoder->getKey(0xc0, 0xa8, 0x02, 0xaa, 16, key)) { // for 192.168.2.170, ch 16
        printf("%d, %d, %d, %d, %d -> key=%u\n", 0xc0, 0xa8, 0x02, 0xaa, 16, key);
        auto config = decoder->getTriggerConfig(key);
        printf("\tkey=%u: iSubTimeRegion=%u hitBit=%u delay=%d width=%u\n", key, config.iSubTimeRegion, config.hitBit, config.delay, config.width);
    }
    else {
        printf("Failed to get key for 192.168.2.170, ch 16\n");
    }
} // __global__ void testDecoder(const cudamap::FEEAddrDecoder* decoder)

int main(int argc, char* argv[]){
    const std::string funcName = "[cudamap.cu/main] ";
    std::cout << funcName << "start" << std::endl;
    // warm-up the GPU
    std::chrono::high_resolution_clock::time_point start, end;
    start = std::chrono::high_resolution_clock::now();
    doWarmUp<<<1, 1>>>();
    cudaDeviceSynchronize();
    end = std::chrono::high_resolution_clock::now();
    double warmUpTime = std::chrono::duration<double, std::milli>(end - start).count();
    std::cout << "Warm-up time: " << std::fixed << std::setprecision(2) << warmUpTime << " ms" << std::endl;

    // test cudamap
    cudamap::FEEAddrDecoder decoder;
    std::vector<cudamap::FEEAddr> feeAddrs;
    std::vector<cudamap::TriggerConfig> triggerConfigs;

    // Add some test data
    auto add = [&](uint32_t ip, uint8_t ch,
                uint8_t group, uint8_t subgroup,
                int16_t offset, uint8_t width) {
        std::cout << funcName << "Adding FEEAddr: "
                << static_cast<int>((ip >> 24) & 0xff) << "."
                << static_cast<int>((ip >> 16) & 0xff) << "."
                << static_cast<int>((ip >> 8) & 0xff) << "."
                << static_cast<int>(ip & 0xff) << ", ch: "
                << static_cast<int>(ch)
                << " with TriggerConfig: group=" << static_cast<int>(group)
                << ", subgroup=" << static_cast<int>(subgroup)
                << ", offset=" << offset
                << ", width=" << static_cast<int>(width)
                << std::endl;
        feeAddrs.push_back({static_cast<uint8_t>((ip >> 24) & 0xff), static_cast<uint8_t>((ip >> 16) & 0xff), static_cast<uint8_t>((ip >> 8) & 0xff), static_cast<uint8_t>(ip & 0xff), ch});
        triggerConfigs.push_back({group, subgroup, offset, width});
    };

    uint8_t width = 20;

    // Group 0, 1
    add(0xc0a802a9,  static_cast<uint8_t>(8), static_cast<uint8_t>(0), static_cast<uint8_t>(cudamap::NO_SUBGROUP), static_cast<short>(0), width);
    add(0xc0a802a9, static_cast<uint8_t>(10), static_cast<uint8_t>(1), static_cast<uint8_t>(cudamap::NO_SUBGROUP), static_cast<short>(0), width);
    // Group 2, Subgroup 0
    add(0xc0a802aa, static_cast<uint8_t>(16), static_cast<uint8_t>(2), static_cast<uint8_t>(0), static_cast<short>(-12), width);
    add(0xc0a802aa, static_cast<uint8_t>(17), static_cast<uint8_t>(2), static_cast<uint8_t>(0), static_cast<short>(-12), width);
    // Group 2, Subgroup 1
    add(0xc0a802aa, static_cast<uint8_t>(18), static_cast<uint8_t>(2), static_cast<uint8_t>(1), static_cast<short>(-12), width);
    add(0xc0a802aa, static_cast<uint8_t>(19), static_cast<uint8_t>(2), static_cast<uint8_t>(1), static_cast<short>(-12), width);
    // Group 2, Subgroup 2
    add(0xc0a802aa, static_cast<uint8_t>(20), static_cast<uint8_t>(2), static_cast<uint8_t>(2), static_cast<short>(-12), width);
    add(0xc0a802aa, static_cast<uint8_t>(21), static_cast<uint8_t>(2), static_cast<uint8_t>(2), static_cast<short>(-12), width);
    // Group 2, Subgroup 3
    add(0xc0a802aa, static_cast<uint8_t>(22), static_cast<uint8_t>(2), static_cast<uint8_t>(3), static_cast<short>(-12), width);
    add(0xc0a802aa, static_cast<uint8_t>(23), static_cast<uint8_t>(2), static_cast<uint8_t>(3), static_cast<short>(-12), width);
    // Group 2, Subgroup 4
    add(0xc0a802aa, static_cast<uint8_t>(24), static_cast<uint8_t>(2), static_cast<uint8_t>(4), static_cast<short>(-12), width);
    add(0xc0a802aa, static_cast<uint8_t>(25), static_cast<uint8_t>(2), static_cast<uint8_t>(4), static_cast<short>(-12), width);
    // Group 2, Subgroup 5
    add(0xc0a802aa, static_cast<uint8_t>(27), static_cast<uint8_t>(2), static_cast<uint8_t>(5), static_cast<short>(-12), width);
    add(0xc0a802aa, static_cast<uint8_t>(28), static_cast<uint8_t>(2), static_cast<uint8_t>(5), static_cast<short>(-12), width);

    decoder.initialize(feeAddrs, triggerConfigs);

    // allocate device memory
    int nCongis = decoder.getSizeSpaceOfKey();
    cudamap::TriggerConfig* devTriggerConfigs;
    cudaMalloc(&devTriggerConfigs, nCongis * sizeof(cudamap::TriggerConfig));
    // copy TriggerConfig array to device
    cudaMemcpy(devTriggerConfigs, decoder.getTriggerConfigArray(), nCongis * sizeof(cudamap::TriggerConfig), cudaMemcpyHostToDevice);

    // create a device copy of the decoder
    cudamap::FEEAddrDecoder devDecoder = decoder;
    devDecoder.setTriggerConfigArray(devTriggerConfigs);

    // allocate device memory for the decoder
    cudamap::FEEAddrDecoder* devDecoderPtr;
    cudaMalloc(&devDecoderPtr, sizeof(cudamap::FEEAddrDecoder));
    cudaMemcpy(devDecoderPtr, &devDecoder, sizeof(cudamap::FEEAddrDecoder), cudaMemcpyHostToDevice);

    std::cout << "before testDecoder kernel launch" << std::endl;

    testDecoder<<<1, 1>>>(devDecoderPtr);

    // launch時のエラー
    cudaError_t err = cudaGetLastError();
    std::cout << "launch: "
            << cudaGetErrorString(err)
            << std::endl;

    // 実行時のエラー
    err = cudaDeviceSynchronize();
    std::cout << "sync: "
            << cudaGetErrorString(err)
            << std::endl;

    std::cout << "after testDecoder kernel" << std::endl;

    return 0;
} // int main(int argc, char* argv)

__global__ void doWarmUp()
{
    // do "warm up", and nothing else
    return;
}