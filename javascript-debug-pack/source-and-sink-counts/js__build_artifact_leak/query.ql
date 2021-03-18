

import javascript
import semmle.javascript.security.dataflow.BuildArtifactLeak::BuildArtifactLeak

from string type, int amount
where exists(string qid | qid = "js/build-artifact-leak" and (
  exists(
    Configuration c |
    amount = count(DataFlow::Node n | c.isSource(n)) and type = qid + " | " + c + " | " + "Source" or
    amount = count(DataFlow::Node n | c.isSink(n))   and type = qid + " | " + c + " | " + "Sink"
  )
))
select type, amount
