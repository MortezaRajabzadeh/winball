package economy

import (
	"errors"
	"sync"
	"time"

	"github.com/khodehamid/winball_go_back/cache"
	"github.com/khodehamid/winball_go_back/logger"
	"github.com/sirupsen/logrus"
)

const (
	// Cache keys
	rtpStatsCacheKey  = "rtp_stats"
	houseStatusCacheKey = "house_status"
	
	// Cache expiration duration
	defaultCacheExpiration = 1 * time.Hour
)

// EconomyService manages economic statistics for the game
type EconomyService struct {
	cache *cache.RTFCache
	mu    sync.RWMutex
}

// NewEconomyService creates a new instance of economic statistics service
func NewEconomyService(cache *cache.RTFCache) *EconomyService {
	return &EconomyService{
		cache: cache,
	}
}

// GetRTPStats retrieves RTP statistics from cache
func (s *EconomyService) GetRTPStats() (*RTPStats, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	rtpData, found := s.cache.Get(rtpStatsCacheKey)
	if !found {
		// If not found in cache, create default values
		defaultStats := &RTPStats{
			RTP:       0.95, // Default RTP value
			TotalBets: 0,
			TotalWins: 0,
			UpdatedAt: time.Now(),
		}
		
		s.cache.Set(rtpStatsCacheKey, defaultStats, defaultCacheExpiration)
		return defaultStats, nil
	}
	
	stats, ok := rtpData.(*RTPStats)
	if !ok {
		logger.Error("economy", "RTP data in cache has invalid format", errors.New("invalid cache data"))
		return nil, ErrInvalidCacheData
	}
	
	return stats, nil
}

// UpdateRTPStats updates RTP statistics with new bet and win data
func (s *EconomyService) UpdateRTPStats(betAmount, winAmount float64) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	
	stats, err := s.GetRTPStats()
	if err != nil {
		return err
	}
	
	// If stats are manually set and not expired, don't update them
	if stats.ManuallySet && time.Now().Before(stats.ManualExpires) {
		return nil
	}
	
	// Update statistics
	stats.TotalBets += betAmount
	stats.TotalWins += winAmount
	
	if stats.TotalBets > 0 {
		stats.RTP = stats.TotalWins / stats.TotalBets
	}
	
	stats.UpdatedAt = time.Now()
	
	// Save to cache
	s.cache.Set(rtpStatsCacheKey, stats, defaultCacheExpiration)
	return nil
}

// SetManualRTP manually sets RTP value
func (s *EconomyService) SetManualRTP(rtp float64, expiration time.Duration) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	
	stats, err := s.GetRTPStats()
	if err != nil {
		return err
	}
	
	stats.RTP = rtp
	stats.ManuallySet = true
	stats.ManualExpires = time.Now().Add(expiration)
	stats.UpdatedAt = time.Now()
	
	s.cache.Set(rtpStatsCacheKey, stats, defaultCacheExpiration)
	return nil
}

// GetHouseStatus retrieves current house status
func (s *EconomyService) GetHouseStatus() (*HouseStatus, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	
	statusData, found := s.cache.Get(houseStatusCacheKey)
	if !found {
		// If not found in cache, create default values
		defaultStatus := &HouseStatus{
			TotalBalance:     1000000, // Default balance
			AvailableBalance: 1000000,
			ReservedBalance:  0,
			RiskLevel:        RiskLevelSafe,
			UpdatedAt:        time.Now(),
		}
		
		s.cache.Set(houseStatusCacheKey, defaultStatus, defaultCacheExpiration)
		return defaultStatus, nil
	}
	
	status, ok := statusData.(*HouseStatus)
	if !ok {
		logger.Error("economy", "House status data in cache has invalid format", errors.New("invalid cache data"))
		return nil, ErrInvalidCacheData
	}
	
	return status, nil
}

// UpdateHouseBalance updates house balance information
func (s *EconomyService) UpdateHouseBalance(totalBalance, reservedBalance float64) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	
	status, err := s.GetHouseStatus()
	if err != nil {
		return err
	}
	
	status.TotalBalance = totalBalance
	status.ReservedBalance = reservedBalance
	status.AvailableBalance = totalBalance - reservedBalance
	status.RiskLevel = CalcRiskLevel(totalBalance, reservedBalance)
	status.UpdatedAt = time.Now()
	
	s.cache.Set(houseStatusCacheKey, status, defaultCacheExpiration)
	return nil
}

// Service errors
var (
	ErrInvalidCacheData = errors.New("data in cache has invalid format")
)