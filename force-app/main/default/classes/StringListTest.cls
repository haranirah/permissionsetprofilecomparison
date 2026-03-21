public class StringListTest {
    public static List<String> generateStringList(Integer n) {
        List<String> resultList = new List<String>();
        for (Integer i = 0; i < n; i++) {
            resultList.add('Test ' + i);
        }
        return resultList;
    }
}