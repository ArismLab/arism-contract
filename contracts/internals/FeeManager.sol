// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract FeeManager {
    uint256 internal feePerHour;

    function _setFeePerHour(uint256 _feePerHour) internal {
        feePerHour = _feePerHour;
    }

    function getFee(uint256 timeEpoch) internal view returns (uint256) {
        return feePerHour * timeEpochToHours(timeEpoch);
    }

    function timeEpochToHours(
        uint256 _timeEpoch
    ) internal pure returns (uint256) {
        return (_timeEpoch / 3600);
    }
}
