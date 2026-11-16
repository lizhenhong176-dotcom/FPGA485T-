echo 'UEsDBBQAAAAIAPCZa13fHMlYJwEAAIsCAAAJAAAAcF9uZWcudGNslZJfT8IwFMXf9ylueB86EPEVSoeLC0vcmBKyNLOUsji3etshxPjd5c+yCDwYHvrQ2985OfekKNIFWwvM8lJC+0axQsj22tLbwqzYQuhMFmCbUsH+2CpFAxveX2/uHnpmuZSO0+vbXUsLwxSWSqDZwpD6MLj3pxHM5W7ORZ5rqFhemeQU9AMCoe8Ryl6dzqxz+x9/MHbdv9gnQyGvsK15ladc1OtZWFamuajKaGiRx6ejqjENvYhe5kvOqH3Ca6FjpKR1ukRIY/rsRTP4fkmxyAr5c9QskDO+EvxdwySMRraTXK2bEi+40BF3PIxDiAkJYM4rRFGYupNzMpi43pjFgR8NxhS67e6l4AuzXaVvmdEGRfoB9rJELpr/tXuoix4FE8oOw5b1C1BLAwQUAAAACADwmWtdhTsxI6UAAADqAAAABwAAAHBfbmVnLnZdj00LglAQRff+iostnCciWuamhKIWCaEbXcsrHyY9P/Mh/fvSFkKzuWdguJypmlxJgaFpqaxbNYBbuMunhUYN09qLAh3baQCZOMdRkiVxeroggD70SugwGcayF5DTzTVNfKzIDqMwId8zHse/YQwqk99esmOSzIIdOsTndMk1bs6M6wU3C3oLbn84e3E58vcLB6pFIfJCTPoMHfbB5CTqvJpf1D5QSwMEFAAAAAgA8JlrXbCmouInAQAAiwIAAAkAAABwX3Bvcy50Y2yVkl9vgjAUxd/5FDe+44bOuVetxZERSQayGUMaVgqSMehui9Ms++7zDyFTHxYf+tDb3zk596Qo4oStBeZFlUH3RjJZqe7aUNtSr1giVJ6VYOpKwv6YMkYNGz5cb+4eBjpNM8saDM2+oYRmEispUG9hTF0Y3bvzAJbZbs5FUSioWVHr6BR0PQK+6xDKXq3eonf7H38wtu2/2CdDkV1h2/CyiLlo1jOwqnV7kbVW0CGPT0dVa+o7Ab3MF51R+4TXQsdIUed0CZ+G9NkJFvD9EmOZl9nPUZMgZ3wl+LuCmR9MTCu6WjcnjnehI/Z0HPoQEuLBkteIotRNJ+ekN7OdKQs9NxhNKfS7/UvBF+a7St9yrTSK+APMtEIu2v+1e2iKnngzyg7DjvELUEsDBBQAAAAIAPCZa10+tTENpQAAAOoAAAAHAAAAcF9wb3Mudl2PTQuCUBBF9/6Kiy2cJyJa5qaEohYJoRtbyysfJj2/fUj/vrSF0GzuGRguZ8o6U1JgqBsqqkYN4BYe8mWhVsO0diJHy3YaQCbOcZSkSXw7XRBAHzoldJgMY9EJyOnmekt8rMgOozAh3zOex79hDCqV316yY5LMgh06xOd0yTXuzozrBTcLegtufzh7cTnyd48DNXUvslxM+gwt9sHkJKqsnF/UPlBLAQIUABQAAAAIAPCZa13fHMlYJwEAAIsCAAAJAAAAAAAAAAAAAAAAAAAAAABwX25lZy50Y2xQSwECFAAUAAAACADwmWtdhTsxI6UAAADqAAAABwAAAAAAAAAAAAAAAABOAQAAcF9uZWcudlBLAQIUABQAAAAIAPCZa12wpqLiJwEAAIsCAAAJAAAAAAAAAAAAAAAAABgCAABwX3Bvcy50Y2xQSwECFAAUAAAACADwmWtdPrUxDaUAAADqAAAABwAAAAAAAAAAAAAAAABmAwAAcF9wb3MudlBLBQYAAAAABAAEANgAAAAwBAAAAAA=' | base64 -d > /tmp/clbinv.zip
rm -rf /tmp/clbinv; mkdir -p /tmp/clbinv
unzip -oq /tmp/clbinv.zip -d /tmp/clbinv
tar czf /tmp/clbinv.tgz -C /tmp clbinv
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clbinv
rm -rf $D; mkdir -p $D
tar xzf /tmp/clbinv.tgz -C $D --strip-components=1
cd $D
for t in p_pos p_neg; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1
  if grep -q "DONE_$t" $t.log; then echo "OK $t"; grep "^CHK" $t.log || true; else echo "FAIL $t"; tail -n 6 $t.log; fi
done
tar czf /tmp/clbinv_out.tgz *.bit 2>/dev/null || true
echo INVDONE
