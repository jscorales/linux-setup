backup:
	@bash ./src/backup $(DEST) ||:

mount-drives:
	@bash ./src/mount-drives && touch $@ ||:

# Run using sudo
setup-ubuntu:
	@bash ./src/setup-ubuntu && touch $@ ||:

# Run using regular user (non-sudo)
setup-pop-os: restore
	@bash ./src/setup-pop-os $(SOURCE) && touch $@ ||:

restore:
	@bash ./src/restore $(SOURCE) ||:

clean:
	@rm -f mount-drives setup-pop-os setup-ubuntu ||:
