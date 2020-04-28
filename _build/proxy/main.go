// A simple http -> http reverse proxy intended for use on
// GCP Cloud Run where the proxy target(s) is/are GCP Cloud Functions
package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
)

// config (we build from src in dockefile)
const (
	gcp_cf_project = "teet-lab"
	gcp_cf_region = "europe-west2"
	gcp_cr_entry_port = ":8080"
)

func main() {
	// handler
	http.HandleFunc("/", ProxyRequest)

	// serve
	log.Println("listening on port", gcp_cr_entry_port )
	if err := http.ListenAndServe(gcp_cr_entry_port, nil); err != nil {
		log.Println("failed to bind", err)
	}
}

func ProxyRequest(w http.ResponseWriter, r *http.Request){
	var endpoint *url.URL
	var err error

	if endpoint, err = url.Parse(fmt.Sprintf(
		"http://%s-%s.cloudfunctions.net%s", gcp_cf_region, gcp_cf_project, r.RequestURI)); err != nil {
		log.Println("failed to parse endpoint", err)
	}

	proxy := httputil.NewSingleHostReverseProxy(endpoint)
	r.Host = r.URL.Host
	proxy.ServeHTTP(w, r)
}