#include <stdio.h>
#include <stdlib.h>

double Host_Leibniz(int start, int size, int Acc, double* Host_Leibniz_Array) {
    double result = 0;
    for (int i = 0; i < size; i++) {
        unsigned long count = start + 1 + i;
        result += 8.0 / (16.0 * count * (count - 1.0) + 3.0);
    }
    return result;
}

int main() {
    //ライプニッツの式を計算する際のGPUで一度に計算させる項数
    unsigned const int Acc = 4096 * 4;
    //ライプニッツの式をGPUに計算させる回数
    unsigned const int count = 8;
    //ホスト側メモリ確保
    //中身はheapに確保する(stack overflow対策)
    double* Host_Leibniz_Array[count];

    //countの回数だけ処理を実行
    double re = 0;
    for (int i = 0; i < count; i++) {
        Host_Leibniz_Array[i] = new double[Acc];//heapに確保
        re += Host_Leibniz(i * Acc, Acc, Acc, Host_Leibniz_Array[i]);
    }
    printf("%1.15lf\n", re);
}