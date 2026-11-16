export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bramcasc
cd $D || exit 1
cat > /tmp/n4.b64 <<'B64'
H4sIAN3l8moAA+1VbW/aMBDuZyT+w4lVaqgAJYSXbtM+JMSlaC2pgMIqxKKQGMgKSZQYaIX47zsnoaVQrZqqbqrEfYh9zz13Pp+ds1sqLI7eWURRrFQqwEeU3VGUyqIMUrlYLZUrxapcBlGsVsvVIxDfOzEu85CZAaby1ji7m/sgMvPs+ZQC83zBcf05A2t6l4N42pfKX8QBmLYdPEKyxCHbeQK4vqS5dAp2xZuzbR/PzO1Bwy0oRnxzHxr+Ibo9n80esl85wQxDZ+zGCHyDnzxxvofPg8gsnIKmNztGR7+pXaA9w4I5zcBpFlrKlSpXiASfhEKLKJrRa2idC0MR5Eo2B9uQmkC9VqNDdmjb2Ian6YrRInVBjBU1UbIwN4aBOQMh3lihdvldaWn4FbD+nItTtdd6BBIaaSKLNAXpZChxFmkiaUvH6DWiRN/nmJqoSZxWu4N7VuKBm6L8YlV9ppO6Eg876IaVBFQ0rYWp8UFY8aVyUDmZiGIuuj39MzzINXfmBEz5FV4SVGsoWkOwnah2DXVrfo2Ga6GEnomuPumJc48owpJG50LUHhFWxdWSrreC64qmC3gpk5OJlGGsYHj9WuB3MdHVRB9muTe/bdS1418nnfrfv/CbxC0VmDV93zVe6/9iaaf/SyKOh/7/LySgpm0saOBMvTHgZVikU+GDyyaGTaNmmseXgb8OkPfNgMG9VV3cl87KbDQaS1K5mpeRT5nhB55PA/YAl3otaafGD/m2KEF/jGaLTqdh0vMG6ZQ/NS2arJBOBdjJnzSMBqMJ9DGeyxPyHT+EJTqNPMzVmoDL4pguZSHkJw4NBrCCjdWPjZFX3hsZ3vAXtZB47DJOwxcD5xg/c7yJ85h6U7kicOwPMrCGdTplTb2Qcu7ODtukS7DT38KqZwau447XcRw7sAxrQq27EJrtjpaXBn/veFNr6PuOtfO62m1Dt1bToW/Ng4C6LKnXHlVvnjfqRle/7Ch1AnJBfsFjGThY8KHDQoZFm0Eei2dRXmzE8HR4jTL4VBLDLWU+eH87yEEOcpCDvCy/AV0vTnIAEAAA
B64
base64 -d /tmp/n4.b64 > /tmp/n4.tgz && tar xzf /tmp/n4.tgz -C $D
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $D/n4.tcl > $D/n4.log 2>&1
grep -q DONE_n4 $D/n4.log && echo OK || { echo FAIL; grep -m3 'ERROR:' $D/n4.log; }
base64 -w0 $D/n4.bit > /tmp/n4.b64out; wc -c /tmp/n4.b64out
