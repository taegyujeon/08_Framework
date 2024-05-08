const selectAll = document.querySelector("#selectAll");
const studentList = document.querySelector("#studentList");

const createTd = (text) => {
  const td = document.createElement("td");
  td.innerText = text;
  return td;
}

selectAll.addEventListener("click", ()=>{

  fetch("selectAll")

  .then(response => response.json())
  .then(list => {
      console.log(list);

      studentList.innerHTML = "";

      list.forEach((student, index) => {

        const keyList = ['studentNo', 'studentName', 'studentMajor', 'studentGender'];

        const tr = document.createElement("tr");

        keyList.forEach(key => tr.append(createTd(student[key])));

        studentList.append(tr);

      })

  })

});





