class GenResize_PR():
  def __init__(self, parse_opt, test):
    fpath = '../p4src/includes/resize_pr'
    if test:
      fpath += '_test'
    fpath += '.p4'
    f_resizepr = open(fpath, 'w')

    std_h = open('std_header', 'r')
    f_resizepr.write("/*\n")
    f_resizepr.write(std_h.read())
    f_resizepr.write("\n")
    std_h.close()

    resizepr_d = open('docs/resize_pr_d', 'r')
    f_resizepr.write(resizepr_d.read())
    resizepr_d.close()
    f_resizepr.write("*/\n\n")

    indent = "  "
    out = ""

    for i in range(parse_opt[1]):
      number = ""
      if i < 9:
        number += "0"
      number += str(i+1)
      out = "action a_resize_pr_" + number + "() { pop(ext, "
      out += str(parse_opt[1]) + "); push(ext, " + str(i + 1) + "); }\n"
      f_resizepr.write(out)

    out = "\ntable t_resize_pr {\n"
    out += indent + "reads {\n"
    out += indent + indent + "parse_ctrl.numbytes : exact;\n"
    out += indent + "}\n"
    out += indent + "actions {\n"
    for i in range (parse_opt[1]):
      number = ""
      if i < 9:
        number += "0"
      number += str(i+1)
      out += indent + indent + "a_resize_pr_" + number + ";\n"
    out += indent + "}\n}\n"
    f_resizepr.write(out)

    f_resizepr.close()
