/**
 * jpg画像をpdfに変換する機能を提供するモジュール
 * <pre>
 * <code>
 * import t_panda.jpg2pdf.Jpg2Pdf;
 *
 * import java.io.IOException;
 * import java.nio.file.Files;
 * import java.nio.file.Paths;
 *
 * public class Application {
 *     public static void main(String[] args) throws IOException {
 *         // コマンドライン引数で入出力ファイルを指定するサンプル
 *         if(args.length &lt; 2) {
 *             System.err.println("引数が足りません");
 *             System.err.println("　　　引数1: 出力PDF名");
 *             System.err.println("　引数2以降: 入力JPG名");
 *         }
 *
 *         try (Jpg2Pdf jpg2Pdf = new Jpg2Pdf(Files.newOutputStream(Paths.get(args[0])))) {
 *             for (int i = 1; i &lt; args.length; i++) {
 *                 jpg2Pdf.addJpg(Paths.get(args[i]));
 *             }
 *         }
 *
 *     }
 * }
 * </code>
 * </pre>
 */
module t_panda.jpg2pdf {
    opens t_panda.jpg2pdf;
    exports t_panda.jpg2pdf; 
} 
