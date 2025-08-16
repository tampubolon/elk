package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/spf13/cobra"
)

type LogEntry struct {
	Timestamp     string `json:"timestamp"`
	Microservice  string `json:"microservice"`
	Status        int    `json:"status"`
	ResponseTime  int    `json:"response_time"`
	UserID        string `json:"user_id"`
	TransactionID string `json:"transaction_id"`
	Description   string `json:"description"`
}

type Metrics struct {
	TotalTransactions int     `json:"total_log_entries"`
	ErrorCount        int     `json:"error_count"`
	ErrorRate         float64 `json:"error_rate"`
	AvgResponseTime   float64 `json:"average_response_time"`
}

func parseLogFile(inputFile, outputFile string) error {
	file, err := os.Open(inputFile)
	if err != nil {
		return err
	}
	defer file.Close()

	out, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	defer out.Close()

	scanner := bufio.NewScanner(file)
	id := 1

	for scanner.Scan() {
		line := scanner.Text()
		fields := strings.Fields(line)
		if len(fields) < 7 {
			continue
		}

		timestamp := fields[0] + " " + fields[1]
		microservice := fields[2]
		status, _ := strconv.Atoi(fields[3])
		responseStr := strings.TrimSuffix(fields[4], "ms")
		responseTime, _ := strconv.Atoi(responseStr)
		userID := fields[5]
		transactionID := fields[6]
		description := strings.Join(fields[7:], " ")

		entry := LogEntry{
			Timestamp:     timestamp,
			Microservice:  microservice,
			Status:        status,
			ResponseTime:  responseTime,
			UserID:        userID,
			TransactionID: transactionID,
			Description:   description,
		}

		indexLine := fmt.Sprintf(`{ "index": { "_index": "ecommerce-index", "_id": "%d" } }`, id)
		entryJSON, _ := json.Marshal(entry)

		out.WriteString(indexLine + "\n")
		out.WriteString(string(entryJSON) + "\n")

		id++
	}

	return scanner.Err()
}

func computeMetrics(inputFile, outputFile string) error {
	file, err := os.Open(inputFile)
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	totalTransactions := 0
	errorCount := 0
	totalResponseTime := 0

	for scanner.Scan() {
		line := scanner.Text()
		fields := strings.Fields(line)
		if len(fields) < 7 {
			continue
		}

		status, _ := strconv.Atoi(fields[3])
		responseStr := strings.TrimSuffix(fields[4], "ms")
		responseTime, _ := strconv.Atoi(responseStr)

		totalTransactions++
		totalResponseTime += responseTime
		if status >= 400 {
			errorCount++
		}
	}

	metrics := Metrics{
		TotalTransactions: totalTransactions,
		ErrorCount:        errorCount,
		ErrorRate:         float64(errorCount) / float64(totalTransactions),
		AvgResponseTime:   float64(totalResponseTime) / float64(totalTransactions),
	}

	out, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	defer out.Close()

	enc := json.NewEncoder(out)
	enc.SetIndent("", "  ")
	return enc.Encode(metrics)
}

func main() {
	var inputFile string
	var outputFile string

	var rootCmd = &cobra.Command{Use: "sawitpro"}

	var parseCmd = &cobra.Command{
		Use:   "parse-log",
		Short: "Parse raw log into Elasticsearch bulk JSON format",
		RunE: func(cmd *cobra.Command, args []string) error {
			return parseLogFile(inputFile, outputFile)
		},
	}
	parseCmd.Flags().StringVar(&inputFile, "input", "", "Input log file")
	parseCmd.Flags().StringVar(&outputFile, "output-file", "parsed.json", "Output JSON file")
	parseCmd.MarkFlagRequired("input")

	var metricsCmd = &cobra.Command{
		Use:   "compute-metrics",
		Short: "Compute metrics from log file (error rate, avg response time, etc.)",
		RunE: func(cmd *cobra.Command, args []string) error {
			return computeMetrics(inputFile, outputFile)
		},
	}
	metricsCmd.Flags().StringVar(&inputFile, "input", "", "Input log file")
	metricsCmd.Flags().StringVar(&outputFile, "output-file", "metrics.json", "Output metrics JSON file")
	metricsCmd.MarkFlagRequired("input")

	rootCmd.AddCommand(parseCmd, metricsCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Println("Error:", err)
		os.Exit(1)
	}
}
