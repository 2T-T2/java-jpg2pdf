package t_panda.jpg2pdf;

import t_panda.jpg2pdf.internal.JpgParser;
import t_panda.jpg2pdf.internal.TPMath;

import java.io.Closeable;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 複数のJpg画像を１枚１ページで並べたPdfファイルを作成するクラス
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
public class Jpg2Pdf implements Closeable {
    /** PDFのDPI設定 */
    public static final int PDF_DPI = 72;
    /** モニターのDPI設定 */
    public static final int MONITOR_DPI = 96;

    private final int catalog;
    private final int root;
    private int imageCount;
    private int dataTail;

    private final OutputStream data;
    private final List<Integer> pages;
    private final List<Integer> refs;
    private final HashMap<Integer, Integer> xref;

    /**
     * Pdfを出力するストリームを指定してインスタンスを生成します。
     * @param pdfStream Pdfを出力するストリーム
     * @throws IOException ストリームに対する書き込みエラーが発生した場合
     */
    public Jpg2Pdf(OutputStream pdfStream) throws IOException {
        this.data = pdfStream;
        this.imageCount = 0;
        this.dataTail = 0;
        this.pages = new ArrayList<>();
        this.refs = new ArrayList<>();
        this.xref = new HashMap<>();

        this._write("%PDF-1.7\n");
        this.catalog = _bgn_obj(0);
        this.root = _reserve_obj();
        this._write(
            new HashMap<String, String>() {
                HashMap<String, String> init() {
                    put("Type", "/Catalog");
                    put("Pages", _to_str_pages_value(root, 0));
                    return this;
                }
            }.init()
        );
        this._end_obj();
    }

    /**
     * jpgのPathの指定して追加します
     * @param jpgFilePath 追加するjpg画像のPath
     * @throws IOException 指定されたPathのファイルがjpgではない場合、出力ストリームに対する書き込みでエラーが発生したした場合
     */
    public void addJpg(Path jpgFilePath) throws IOException {
        this.addJpg(Files.readAllBytes(jpgFilePath));
    }

    /**
     * jpgデータ(バイト配列)の指定して追加します
     * @param jpg_bytes 追加するjpg画像データのバイト列
     * @throws IOException 指定されたjpg画像データがjpgではない場合、出力ストリームに対する書き込みでエラーが発生したした場合
     */
    public void addJpg(byte[] jpg_bytes) throws IOException {
        JpgParser.JpgMeta meta = JpgParser.tryParse(jpg_bytes).orElseThrow(() ->
            new IOException("Jpgデータではありませんでした。")
        );

        float pageWidth  = (float) (meta.width) * PDF_DPI / MONITOR_DPI;
        float pageHeight = (float) (meta.height) * PDF_DPI / MONITOR_DPI;

        int img_index = _bgn_obj(-1);
        String col_space = (meta.colorSpace == 1) ? "/DeviceGray" : "/DeviceRGB";
        _write(new HashMap<String, String>() {
            HashMap<String, String> init() {
                put("Type","/XObject");
                put("Subtype","/Image");
                put("Filter","/DCTDecode");
                put("BitsPerComponent","8");
                put("ColorSpace",col_space);
                put("Width",Integer.toString(meta.width));
                put("Height",Integer.toString(meta.height));
                put("Length",Integer.toString(jpg_bytes.length));
                return this;
            }
        }.init());
        _write("stream\n");
        _writeJpg(jpg_bytes);
        _write("endstream\n");
        _end_obj();

        int cts_index = _bgn_obj(-1);
        _write(new HashMap<String, String>() {
            HashMap<String, String> init() {
                put("Length",_to_str_pages_value(cts_index + 1, 0));
                return this;
            }
        }.init());
        _write("stream\n");
        int bgn_fp = dataTail;
        _write("q\n1 0 0 1 0.00 0.00 cm\n");
        _write(_to_str_page_size_value(pageWidth, pageHeight));
        _write("/I"+(imageCount)+" Do\nQ\n");
        int len = dataTail - bgn_fp;
        _write("endstream\n");
        _end_obj();

        _bgn_obj(-1);
        _write((len) + "\n");
        _end_obj();

        int rsc_index = _bgn_obj(-1);
        String procset = (meta.colorSpace == 1) ? "ImageB" : "ImageC";
        _write(new HashMap<String, String>() {
            HashMap<String, String> init() {
                put("ProcSet", "[/PDF /"+procset+"]");
                put("XObject", _to_str_dic(new HashMap<String, String>() {
                    HashMap<String, String> init() {
                        put("I"+(imageCount), _to_str_pages_value(img_index, 0));
                        return this;
                    }
                }.init()));
                return this;
            }
        }.init());
        _end_obj();

        int page_index = _bgn_obj(-1);
        pages.add(page_index);
        _write(new HashMap<String, String>() {
            HashMap<String, String> init() {
                put("Type","/Page");
                put("Parent",_to_str_pages_value(root, 0));
                put("MediaBox",_to_str_mediabox_value(pageWidth, pageHeight));
                put("Contents",_to_str_pages_value(cts_index, 0));
                put("Resources",_to_str_pages_value(rsc_index, 0));
                return this;
            }
        }.init());
        _end_obj();

        imageCount++;
    }

    private boolean isClose = false;
    /**
     * pdfデータの書き込みを終了します
     * @param isCloseStream コンストラクタで指定された出力ストリームも同時に閉じるかどうか。true: 閉じる, false: 閉じない
     * @throws IOException 出力ストリームに対する書き込み、クローズ処理で失敗した場合
     */
    public void close(boolean isCloseStream) throws IOException {
        if(isClose) return;

        _bgn_obj(root);
        _write(new HashMap<String, String>() {
            HashMap<String, String> init() {
                put("Type","/Pages");
                put("Kids",_get_str_kids_value());
                put("Count",Integer.toString(pages.size()));
                return this;
            }
        }.init());
        _end_obj();

        int xref_fp = dataTail;
        _write("xref\n");
        _write("0 " + (xref.size()+1) + "\n");
        _write("0000000000 65535 f\n");
        for(int v : this.xref.values()) {
            _write(String.format("%010d", v) + " 00000 n\n");
        }
        _write("trailer\n");
        _write(new HashMap<String, String>() {
            HashMap<String, String> init() {
                put("Root", _to_str_pages_value(catalog, 0));
                put("Size", Integer.toString(xref.size() + 1));
                return this;
            }
        }.init());
        _write("startxref\n"+(xref_fp)+"\n");
        _write("%%EOF\n");
        isClose = true;

        if(isCloseStream)
            data.close();
    }
    /**
     * pdfデータの書き込みを終了します、同時に出力ストリームのクローズ処理を行います。
     * @throws IOException 出力ストリームに対する書き込み、クローズ処理で失敗した場合
     */
    @Override
    public void close() throws IOException {
        close(true);
    }

    private void _writeJpg(byte[] jpg) throws IOException {
        data.write(jpg);
        dataTail += jpg.length;
    }
    private void _write(String str) throws IOException {
        data.write(str.getBytes());
        this.dataTail += str.length();
    }
    private void _write(int i) throws IOException {
        this._write(Integer.toString(i));
    }
    private void _write(HashMap<String, String> dic) throws IOException {
        _write(_to_str_dic(dic));
    }
    private String _to_str_dic(HashMap<String, String> dic) {
        return new StringBuilder("<<\n")
                .append(dic.entrySet().stream().map((keyValue) ->
                                        new StringBuilder("/")
                                                .append(keyValue.getKey())
                                                .append(' ')
                                                .append(keyValue.getValue())
                                                .append(' ')
                                )
                                .reduce(StringBuilder::append)
                                .orElseThrow(IllegalAccessError::new)
                )
                .append(">>\n")
                .toString();
    }
    private String _to_str_pages_value(int i, int j) {
        return new StringBuilder(Integer.toString(i+1))
                .append(' ')
                .append(j)
                .append(" R")
                .toString();
    }
    private String _to_str_page_size_value(float f1, float f2) {
        return new StringBuilder(Double.toString(TPMath.nFloor(f1, 2)))
                .append(" 0 0 ")
                .append(TPMath.nFloor(f2, 2))
                .append(" 0 0 cm\n")
                .toString();
    }
    private String _to_str_mediabox_value(float f1, float f2) {
        return new StringBuilder("[0.0 0.0 ")
                .append(TPMath.nFloor(f1, 2))
                .append(' ')
                .append(TPMath.nFloor(f2, 2))
                .append(']')
                .toString();
    }
    private String _get_str_kids_value() {
        return new StringBuilder("[")
                .append(pages.stream().map((it) ->
                                        new StringBuilder(_to_str_pages_value(it, 0))
                                                .append(" ")
                                )
                                .reduce(StringBuilder::append)
                                .orElseThrow(IllegalStateException::new)
                )
                .append("]")
                .toString();
    }
    private int _reserve_obj(){
        int i = this.refs.size() + 1;
        this.refs.add(i);
        return i;
    }
    private int _bgn_obj(int reserved) throws IOException {
        int i;
        if(reserved != -1) i = reserved;
        else {
            i = this.refs.size() + 1;
            this.refs.add(i);
        }
        xref.put(i, this.dataTail);
        _write(new StringBuilder(Integer.toString(i+1))
                .append(" 0 obj\n")
                .toString());

        return i;
    }
    private void _end_obj() throws IOException {
        _write("endobj\n");
    }
}
