/**
 * @name Sources and Sinks
 * @description Prints sources and sinks of various DataFlow and TaintTracking Configurations
 * @kind problem
 * @problem.severity recommendation
 * @id java/hardcoded-credential-api-call-sources-and-sinks
 */


import java
import semmle.code.java.dataflow.DataFlow
import HardcodedCredentials


class HardcodedCredentialApiCallConfiguration extends DataFlow::Configuration {
  HardcodedCredentialApiCallConfiguration() { this = "HardcodedCredentialApiCallConfiguration" }

  override predicate isSource(DataFlow::Node n) {
    n.asExpr() instanceof HardcodedExpr and
    not n.asExpr().getEnclosingCallable().getName() = "toString"
  }

  override predicate isSink(DataFlow::Node n) { n.asExpr() instanceof CredentialsApiSink }

  override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    node1.asExpr().getType() instanceof TypeString and
    exists(MethodAccess ma | ma.getMethod().getName().regexpMatch("getBytes|toCharArray") |
      node2.asExpr() = ma and
      ma.getQualifier() = node1.asExpr()
    )
  }

  override predicate isBarrier(DataFlow::Node n) {
    n.asExpr().(MethodAccess).getMethod() instanceof MethodSystemGetenv
  }
}

from DataFlow::Node n, string type
where exists(string qid | qid = "java/hardcoded-credential-api-call" and (
  exists(
    HardcodedCredentialApiCallConfiguration c |
    c.isSource(n) and type = qid + " | " + c + " | " + "Source" or
    c.isSink(n)   and type = qid + " | " + c + " | " + "Sink"
  )
))
select n, type
