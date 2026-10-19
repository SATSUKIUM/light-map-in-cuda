#ifndef CUDAMAP_H
#define CUDAMAP_H

#include <cstdint>
#include <vector>
#include <cuda_runtime.h>

namespace cudamap {

    constexpr uint8_t NO_SUBGROUP = UINT8_MAX; // 255, reserved for "no sub-group"

    struct TriggerConfig
    {
        uint32_t hitBit{};
        uint8_t  iSubTimeRegion{};
        int16_t  delay{};
        uint8_t  width{};
        __host__ __device__ bool isValid() const { return width != (uint8_t)0; } // (width == 0) is reserved for invalid TriggerConfig
        __host__ __device__ void print() const;
    }; // struct TriggerConfig

    struct FEEAddr
    {
        uint8_t ip1st{};
        uint8_t ip2nd{};
        uint8_t ip3rd{};
        uint8_t ip4th{};
        uint8_t ch{};
    }; // struct FEEAddr


    class FEEAddrDecoder
    {
    public:
        FEEAddrDecoder() = default;

        bool initialize(const std::vector<FEEAddr>& feeAddrArray, const std::vector<TriggerConfig>& triggerConfigArray);
        __host__ __device__ bool getKey(uint8_t ip1st, uint8_t ip2nd, uint8_t ip3rd, uint8_t ip4th, uint8_t ch, uint32_t& key) const;
        __host__ __device__ bool getKey(uint32_t ip, uint8_t ch, uint32_t& key) const;
        __host__ bool calcKey(uint8_t ip1st, uint8_t ip2nd, uint8_t ip3rd, uint8_t ip4th, uint8_t ch, uint32_t& key) const;
        __host__ __device__ TriggerConfig getTriggerConfig(uint32_t key) const;
        uint32_t getSizeSpaceOfKey() const{ return sizeSpaceOfKey; }
        const TriggerConfig* getTriggerConfigArray() const{ return triggerConfigArray; }
        void setTriggerConfigArray(TriggerConfig* ptr){ triggerConfigArray = ptr; }

    private:
        uint8_t minIP1st{};
        uint8_t maxIP1st{};
        uint8_t minIP2nd{};
        uint8_t maxIP2nd{};
        uint8_t minIP3rd{};
        uint8_t maxIP3rd{};
        uint8_t minIP4th{};
        uint8_t maxIP4th{};
        uint8_t minCh{};
        uint8_t maxCh{};

        uint16_t sizeSpaceOfIP1st{};
        uint16_t sizeSpaceOfIP2nd{};
        uint16_t sizeSpaceOfIP3rd{};
        uint16_t sizeSpaceOfIP4th{};
        uint32_t strideCh{};
        uint32_t strideIP4th{};
        uint32_t strideIP3rd{};
        uint32_t strideIP2nd{};
        uint32_t strideIP1st{};
        uint16_t sizeSpaceOfCh{};

        uint32_t sizeSpaceOfKey{};

        TriggerConfig* triggerConfigArray{nullptr};
    }; // class FEEAddrDecoder

    void stageItem(uint32_t ip, uint8_t ch, uint32_t hitBit, uint8_t width, int16_t offset, uint8_t iSubTimeRegion, std::vector<FEEAddr>& feeAddrArray, std::vector<TriggerConfig>& triggerConfigArray);

} // namespace cudamap

#endif // CUDAMAP_H