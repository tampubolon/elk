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

func main() {
    var inputFile string
    var outputFile string

    var rootCmd = &cobra.Command{Use: "logcli"}

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

    rootCmd.AddCommand(parseCmd)

    if err := rootCmd.Execute(); err != nil {
        fmt.Println("Error:", err)
        os.Exit(1)
    }
}
