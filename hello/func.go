package hello

import (
	"fmt"
	"net/http"
	"github.com/teetlab/pkg/utilities"
)

func TestHello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, utilities.MyString())
}
