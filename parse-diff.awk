/<object>/ {
  obj=$0
  gsub(/.*<|>.*/, "", obj)
}

/allow(Create|Edit|Delete|Read)/ {
  if ($0 ~ /^\+/) {
    orgLine=$0
    getline nextLine

    if (nextLine ~ /^-/) {
      branchLine=nextLine

      orgVal=orgLine
      branchVal=branchLine

      gsub(/.*<|>.*/, "", orgVal)
      gsub(/.*<|>.*/, "", branchVal)

      perm=orgLine
      gsub(/.*<|>.*/, "", perm)

      if (orgVal != branchVal) {
        print "Object: " obj
        print "  • " perm " : " orgVal " ➜ " branchVal
      }
    }
  }
}