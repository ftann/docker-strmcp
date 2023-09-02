package cli

import (
	"context"
	"github.com/spf13/cobra"
)

type ExitCode = int

const (
	ExitSuccess ExitCode = iota
	ExitFailure
)

func Run(ctx context.Context, cmd *cobra.Command) ExitCode {
	if err := cmd.ExecuteContext(ctx); err != nil {
		return ExitFailure
	}
	return ExitSuccess
}
