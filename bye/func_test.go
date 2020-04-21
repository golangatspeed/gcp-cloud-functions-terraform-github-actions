package bye

import "testing"


func TestTestable(t *testing.T) {
	res:= MyTestable()
	if res != 3 {
		t.Error("wrong answer")
	}
}
