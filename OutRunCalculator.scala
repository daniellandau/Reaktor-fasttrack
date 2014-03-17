import scala.util.parsing.combinator._
import scala.io.Source

class OutRunParser extends JavaTokenParsers {
  override val skipWhitespace = false
  def int: Parser[Int] = wholeNumber ^^ (_.toInt)
  def ints: Parser[List[Int]] = repsep(int, """[ \t]+""".r)
  def tree: Parser[List[List[Int]]] = repsep(ints, """\n""".r)
}

  

object OutRunCalculator extends OutRunParser {
  def joinLines( acc: List[Int], x: List[Int] ) : List[Int]  = {
    if (x.length + 1 != acc.length) {
      throw new IllegalArgumentException("Puun tulisi kasvaa yhdellä luvulla joka rivillä")
    }
    var newAcc : List[Int] = Nil
    for (i <- 0 until x.length) {
      newAcc = x(i) + math.max(acc(i), acc(i+1)) :: newAcc
    }
    return newAcc.reverse
  }

  def main(args: Array[String]) {
    if (args.length != 1) {
      throw new IllegalArgumentException("Anna tiedoston nimi tai URL argumenttina")
    }
    var source: Source = null
    if (args(0).startsWith("http")) {
      source = Source.fromURL(args(0))
    } else {
      source = Source.fromFile(args(0))
    }
    val lines = source.getLines.toList
    println(lines.head)
    val treeLines = lines.tail.mkString("\n")
    val result = parseAll(tree, treeLines)
    result match {
      case Success(tree, _) => {
        val reversed = tree.reverse
        val res = reversed.tail.foldLeft[List[Int]]( reversed.head)( joinLines).head
        println(s"$res tykkäystä")
      }
      case _ => throw new IllegalArgumentException("Puu ei ollut oikein muodostettu")
    } 
  }
}

