package main

import (
	"context"
	"github.com/ftann/trigger/internal/pkg/app"
	"github.com/ftann/trigger/internal/pkg/cli"
	"github.com/spf13/cobra"
	"log"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM, syscall.SIGINT, syscall.SIGPIPE)
	defer cancel()

	cli.Run(ctx, newTriggerCmd())
}

func newTriggerCmd() *cobra.Command {
	return &cobra.Command{
		Use: "trigger",
		RunE: func(_ *cobra.Command, _ []string) error {
			log.Println("start server")
			if err := app.ServeRestartTrigger(); err != nil {
				log.Printf("server failed: %v\n", err.Error())
				return err
			}
			log.Println("stopped server")
			return nil
		},
	}
}
