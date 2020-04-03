ArrayList<Element> circuit = new ArrayList<Element>;







for (i = 0; i != circuit.size(); i++) {
    getElm(i).show(g);
}




Element getElm(int n) {
  if (n >= circuit.size()){
      return null;
  }else{
    return circuit.get(n);
  }
}
