package app

import (
	"context"
	"errors"
	"fmt"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
	"net/http"
	"time"
)

const (
	addr  = ":8080"
	label = "strmcp.trigger.enable"
)

func ServeRestartTrigger() error {
	cli, cliErr := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if cliErr != nil {
		return fmt.Errorf("create docker client failed: %w", cliErr)
	}
	defer func() {
		_ = cli.Close()
	}()

	server := &http.Server{
		Addr:              addr,
		Handler:           newRestartHandler(cli, label),
		ReadHeaderTimeout: 3 * time.Second,
	}
	httpErr := server.ListenAndServe()
	if !errors.Is(httpErr, http.ErrServerClosed) {
		return fmt.Errorf("http server failed: %w", httpErr)
	}

	return nil
}

func newRestartHandler(cli *client.Client, label string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		if err := restartAllWithLabel(req.Context(), cli, label); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		w.WriteHeader(http.StatusOK)
	})
}

func restartAllWithLabel(ctx context.Context, cli *client.Client, label string) error {
	containers, err := cli.ContainerList(ctx, types.ContainerListOptions{})
	if err != nil {
		return fmt.Errorf("list containers failed: %w", err)
	}

	for _, c := range containers {
		if hasEnabledLabel(label, c) {
			restartErr := cli.ContainerRestart(ctx, c.ID, container.StopOptions{})
			if restartErr != nil {
				return fmt.Errorf("restart container %v failed: %w", c.ID[:10], restartErr)
			}
		}
	}

	return nil
}

func hasEnabledLabel(label string, c types.Container) bool {
	l, ok := c.Labels[label]
	return ok && l == "true"
}
