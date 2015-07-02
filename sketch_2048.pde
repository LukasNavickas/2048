int[][] blocksArray = new int[4][4]; // array for 4x4 blocks
int Spacing = 20; // padding of 20px between blocks
int BlockSize  = 100; // Size of the block 100x100
int TotalLength = Spacing*(blocksArray.length+1)+BlockSize*blocksArray.length; // Size of the window = blocks + padding
int over = 0;
int Points = 0;

void setup() {
   size(TotalLength, TotalLength); // Board size 
   restart(); // (Re)start the game
}

void store() {
 ArrayList<Integer> TotalX = new ArrayList<Integer>(), TotalY = new ArrayList<Integer>(); // Store all empty positions of TotalX and TotalY
 for(int j = 0; j < blocksArray.length; j++)
    for(int i = 0; i < blocksArray[j].length; i++)
         if(blocksArray[j][i] == 0) { // if the position is empty, add to respective array list
            TotalX.add(i);
            TotalY.add(j);
         } 
         
         int rand = (int)random(0, TotalX.size()), y = TotalY.get(rand), x = TotalX.get(rand); // picks random empty position and puts either 2 or 4
         blocksArray[y][x] = random(0, 1) < 0.9 ? 2 : 4;
}

void draw() {
 background(255); // Draws the window
 paintRect(0, 0, width, height, 10, color(150)); // Draws the board
 for(int j = 0; j < blocksArray.length; j++) 
   for(int i = 0; i < blocksArray[j].length; i++) {
     float x = Spacing+(Spacing+BlockSize)*i, y = Spacing+(Spacing+BlockSize)*j;
     paintRect(x, y, BlockSize, BlockSize, 5, color(200)); // draws 4x4 cubes
     if(blocksArray[j][i] > 0) { // If array contains information, handle these positions differently
        float p = log(blocksArray[j][i])/log(2); // color depends on the number, depends on the power of 2
         paintRect(x, y, BlockSize, BlockSize, 5, color(255-p*255/11, p*255/11, 0)); // Choses the color for differently numbered cubes
         
         writeText(""+blocksArray[j][i], x, y+22, BlockSize, BlockSize, color(0), 48, CENTER); // Writes the numbers in the cubes
     }
 }
    writeText("Points: "+Points, 10, 5, 100, 50, color(0), 10, LEFT);
    if(over > 0) {
       paintRect(0, 0, width, height, 0, color(255, 100)); // transparent text
       writeText("Gameover! Click to restart", 0, height/2, width, 50, color(0), 30, CENTER); // puts the transparent Gameover text on the screen
       if(mousePressed) restart();
    }
}

void keyPressed() { 
   if(over == 0) { // Can move only if not over
      int kC = keyCode;
      int MovementY = kC == UP ? -1 : (kC == DOWN ? 1 : 0); 
      int MovementX = kC == LEFT ? -1 : (kC == RIGHT ? 1 : 0);
      int[][] newBoard = initiate(MovementY, MovementX, true); // loads the newboard
      
      if(newBoard != null) { // if it was successful
         blocksArray = newBoard;
        store(); 
      }
        if(gameover()) over = 1; // dead screen if the game is over...
      
   } 
}

boolean gameover() {
   int[] MovementX = {1, -1, 0, 0}, MovementY = {0, 0, 1, -1}; // down-up, left-right
   boolean out = true;
   
   for(int i = 0; i < 4; i++) 
      if(initiate(MovementY[i], MovementX[i], false) != null) // if you are able to go, game is not over 
        out = false;
        
   return out; 
}

int[][] initiate(int MovementY, int MovementX, boolean updatescore) { // moves up-down, moves right-left, updates score
  int[][] board = new int[4][4];
  for(int j = 0; j < 4; j++)    // iterates through the board 
    for(int  i = 0; i < 4; i++)
      board[j][i] = blocksArray[j][i]; // creates copy of the board
      
      boolean Changed = false;
      
      if(MovementX != 0 || MovementY != 0) { // we run this function only, if...
        int d = MovementX != 0 ? MovementX : MovementY;
        for(int Perpotion = 0; Perpotion < blocksArray.length; Perpotion++) 
          for(int Touchable = (d > 0 ? blocksArray.length - 2 : 1); Touchable != (d > 0 ? -1 : blocksArray.length); Touchable -= d) { // apply the order of moving of the gravity, move everyone in the same direction
                   int y = MovementX != 0 ? Perpotion : Touchable; 
                   int x = MovementX != 0 ? Touchable : Perpotion; 
                   int targetY = y, targetX = x; // target positions
                   
                   if(board[y][x] == 0) continue;
                   for(int i = (MovementX != 0 ? x : y) + d; i!= ( d > 0 ? blocksArray.length : -1); i+=d) { // slides it if it has empty positions 
                      int r = MovementX != 0 ? y : i, c = MovementX != 0 ? i : x;
                         if(board[r][c] != 0  && board[r][c] != blocksArray[y][x]) break; // stops if not zero, keeps moving otherwise
                         if(MovementX != 0) targetX = i;
                         else targetY = i; 
                   }
                   
                   // x and y are the block position, tx and ty are where the block is sliding to
                   if( (MovementX != 0 && targetX == x) || (MovementY != 0 && targetY == y)) continue;
                   else if(board[targetY][targetX] == blocksArray[y][x]) {
                      board[targetY][targetX] *= 2; // we merge the blocks if they are equal and moved in the same direction
                      if(updatescore) Points += board[targetY][targetX];
                         Changed = true; 
                   } else if( (MovementX != 0 && targetX != x) || (MovementY != 0 && targetY != y)) { 
                      board[targetY][targetX] = board[y][x]; // otherwise slide into empty position
                     Changed = true; 
                   }
                   
                   if(Changed) board[y][x] = 0;
                 } 
      }
     return Changed ? board : null;   
     

}

void paintRect(float x, float y, float w, float h, float r, color c) { // x position, y position, witdh, height, radius, color
  fill(c);
  rect(x, y, w, h, r); 
}

void writeText(String t, float x, float y, float w, float h, color c, float s, int align) {  // text, x position, y position, boundary box, color, font size, align or not
  fill(c);
  textAlign(align);
  textSize(s);
  text(t, x, y, w, h); 
}

void restart() { // Restart the game and reset the settings
  blocksArray = new int[4][4];
  Points = over = 0;
  noStroke(); // removes black border
  store();
}
