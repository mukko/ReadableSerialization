ReadableSerialization
=====================
ReadableSerialization��haxe.Serializer.run()���ꂽ�f�[�^��json�`���ɐ��`���A�o�͂���@�\�������܂��B  
�܂��A�o�͂��ꂽ���`�V���A���C�Y�f�[�^��haxe.Unserializer.run()���邱�Ƃ��ł��܂��B    

---
#### �f�B���N�g���\��(2015/04/27����)
sr.n  
sw.n  
�Ɠ����f�B���N�g���Ƀe�L�X�g�t�@�C����p�ӂ��Ă��������B

---
#### ��̗�    
�ȉ���Point�N���X���`�����Ƃ���B
  
    class Point {  
        public var x(default, null) : Int; 
        public var y(default, null) : Int;  

        public function new(x : Int , y : Int) {
		    this.x = x;
		    this.y = y;
	    }
    }


�R�[�h���Ń|�C���g�^�̃C���X�^���X��  
x = 10,
y = 20,
�Ƃ��č쐬�����Ƃ��A������V���A���C�Y�����(haxe.Serializer.run())


    cy5:Pointy1:xi10y1:yi20g


�Ƃ���������𓾂邱�Ƃ��ł���B  
���̕������Ⴆ��point.txt�`���ŕۑ����A  
### �R�}���h
    > neko sr point.txt
 
�Ɠ��͂��邱�ƂŁAjson�`���ɐ��`�����f�[�^"sr_point.txt.txt"���o�͂���

    //sr_point.txt.txt
    "" : SClass(Point) = {
	    "x" : SInt = 10,
	    "y" : SInt = 20,
    },

�ȉ���ƒ�