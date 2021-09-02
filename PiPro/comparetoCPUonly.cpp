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
    //���C�v�j�b�c�̎����v�Z����ۂ�GPU�ň�x�Ɍv�Z�����鍀��
    unsigned const int Acc = 4096 * 4;
    //���C�v�j�b�c�̎���GPU�Ɍv�Z�������
    unsigned const int count = 8;
    //�z�X�g���������m��
    //���g��heap�Ɋm�ۂ���(stack overflow�΍�)
    double* Host_Leibniz_Array[count];

    //count�̉񐔂������������s
    double re = 0;
    for (int i = 0; i < count; i++) {
        Host_Leibniz_Array[i] = new double[Acc];//heap�Ɋm��
        re += Host_Leibniz(i * Acc, Acc, Acc, Host_Leibniz_Array[i]);
    }
    printf("%1.15lf\n", re);
}